//+------------------------------------------------------------------+
//|                                  TewiMiCOnePeriodOneParamSet.mq4 |
//|                                   Copyright 2013, Artur Pietrzyk |
//|                                            http://wi.zut.edu.pl/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Artur Pietrzyk"
#property link      "http://wi.zut.edu.pl/"
#define MAGIC 2858240

#define BANDS "Bands_MinMax_Fast"
#define BANDS_HI 1
#define BANDS_LO 2

#define VOLUME_MEAN "VolumeMean"
#define VOLUME_MEAN_M 0

//--- input parameters
extern double    B=-0.0009;
extern int       WSTP=20;
extern int       WSTK=3;
extern int       LKR_MaxDuration=10;
extern double    SL=0.0060; 
extern double    TP=0.0020; 
extern int       OP_MaxOpenPositions=2;
extern int       BVOL_VolumeMeanThreshold=120;
extern int       VWST_VolumeMeanPeriod=4;
extern int       LL3=10;
extern double    BAWE=0.0011;
extern double    BCAWE=0.0019;

//--- variables
int      cawe = 1;
int      pawe = 1;
int      LogFileHandle = 0;

//--- bands configuration values
double    BandsPeriod;
int       BandsShift;

//---- profit in price buffer
double   ProfitInPriceHistory[];
double   ProfitInPrice = 0;
int      ProfitInPricePosition;
int      ProfitInPriceHistoryLength;

//---- trades buffer
int         TradeTicket[];
datetime    TradeOpenCandleTime[];
int         Trades=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//--- convert arguments from matlab to metatrader
   WSTP--;
   WSTK--;
   
//--- calculate configuration values
   BandsPeriod = WSTP - WSTK;
   BandsShift = WSTK;

//--- init profit in price buffer
   ProfitInPriceHistoryLength = 256;
   if (LL3 >= ProfitInPriceHistoryLength)
   {
      ProfitInPriceHistoryLength = LL3 * 2;
   }
   ProfitInPricePosition = 0;
   ArrayResize(ProfitInPriceHistory, ProfitInPriceHistoryLength);
   ProfitInPriceHistory[ProfitInPricePosition] = ProfitInPrice;
   ProfitInPricePosition++;
   
//--- init trades buffer
   int TradeArraysSize = 65536;
   ArrayResize(TradeTicket, TradeArraysSize);
   ArrayResize(TradeOpenCandleTime, TradeArraysSize);
   for (int idx = 0; idx < TradeArraysSize; idx++)
   {
      TradeTicket[idx] = EMPTY_VALUE;
   }
   
//---- because matlab working on current candle closing, 
//---- we need working on next candle opening
   LKR_MaxDuration++;
   
//----
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//----
   
//----
   return(0);
}
//+------------------------------------------------------------------+
//| function counts opened orders by this ea                         |
//+------------------------------------------------------------------+
int OpenedOrdersCount()
{
   int orders = 0;
   int idx;
   
   for (idx=0; idx < OrdersTotal(); idx++)
   {
      if (OrderSelect(idx, SELECT_BY_POS, MODE_TRADES) == false)
      {
         break;
      }
      if (OrderMagicNumber() != MAGIC)
      {
         continue;
      }

      orders++;
   }
   
   return (orders);
}
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
{
   int type, ticket;
   string comment;
//---- get indicator values
   double LowerBuffer = iCustom(NULL, 0, BANDS, BandsPeriod, BandsShift, BANDS_LO, 0);
   double UpperBuffer = iCustom(NULL, 0, BANDS, BandsPeriod, BandsShift, BANDS_HI, 0);
   double VolumeMean = iCustom(NULL, 0, VOLUME_MEAN, VWST_VolumeMeanPeriod, VOLUME_MEAN_M, 0);
//---- you will not open more orders
   if (OpenedOrdersCount() >= OP_MaxOpenPositions)
   {
      return;
   }

//---- volume filtering
   VolumeMean = - VolumeMean + Volume[0];

//---- horizontal
   if (VolumeMean > BVOL_VolumeMeanThreshold)
   {
      return;
   }
 
//--- opening type 1 & 2.
//--- assertion used on candle opening: Open = High = Low.
   if (Low[0] < LowerBuffer - B && cawe == 1 && pawe == 1)
   {
      type = OP_BUY;
      comment = "[TewiMiCOnePeriodOneParamSet] Opening type C, based on " + BANDS;
      
      ticket = EnterMarket(type, comment, Blue);
      if (ticket < 0)
      {
         Print("OrderSend failed with error #", GetLastError());
         return(0);
      }

      AddTrade(ticket, Time[0]);
   }
}
//+------------------------------------------------------------------+
//| Current price                                                    |
//+------------------------------------------------------------------+
double PriceCurrent(int order_type)
{
   if (order_type == OP_BUY)
   {
      return (Ask);
   }
   else if (order_type == OP_SELL)
   {
      return (Bid);
   }
   
   Alert("InvalidState");
}
//+------------------------------------------------------------------+
//| Contr order type                                                 |
//+------------------------------------------------------------------+
int ContrType(int order_type)
{
   if (order_type == OP_BUY)
   {
      return (OP_SELL);
   }
   else if (order_type == OP_SELL)
   {
      return (OP_BUY);
   }
   
   Alert("InvalidState");
}
//+------------------------------------------------------------------+
//| Enter Market                                                     |
//+------------------------------------------------------------------+
int EnterMarket(int type, string comment, color Color=CLR_NONE)
{
   double __sl, __tp;
   if (type == OP_BUY)
   {
      __sl = PriceCurrent(ContrType(type)) - SL;
      __tp = PriceCurrent(ContrType(type)) + TP;
   }
   else if (type == OP_SELL)
   {
      __sl = PriceCurrent(ContrType(type)) + SL;
      __tp = PriceCurrent(ContrType(type)) - TP;
   }
   int ticket = OrderSend(Symbol(), type, 0.1, PriceCurrent(type), 3, __sl, __tp, 
      comment, MAGIC, 0, Color);
   return (ticket);
}
//+------------------------------------------------------------------+
//| Close selected order                                             |
//+------------------------------------------------------------------+
bool CloseSelectedOrder(color Color=CLR_NONE)
{
   DeleteTrade(OrderTicket());
   OrderClose(OrderTicket(), OrderLots(), PriceCurrent(ContrType(OrderType())), 3, 
      Color);
   ProfitInPrice += OrderClosePrice() - OrderOpenPrice();
   return (true);
}
//+------------------------------------------------------------------+
//| Candle opening time by ticket                                    |
//+------------------------------------------------------------------+
datetime GetTradeOpenCandleTimeByTicket(int ticket)
{
   int result = 0;
   int count = ArraySize(TradeTicket);
   int idx;
   
   for (idx = 0; idx < count; idx++)
   {
      if (TradeTicket[idx] == ticket)
      {
         return (TradeOpenCandleTime[idx]);
      }
   }
   
   return (result);
}
//+------------------------------------------------------------------+
//| Add order                                                        |
//+------------------------------------------------------------------+
bool AddTrade(int ticket, datetime dt)
{
   int idx;
   int count = ArraySize(TradeTicket);

   if (Trades >= count)
   {
      Alert("Cant have more than ", count, " open trades in same time.");
      return (false);
   }
      
   for (idx = 0; idx < count; idx++)
   {
      if (TradeTicket[idx] == EMPTY_VALUE)
      {
         TradeTicket[idx] = ticket;
         TradeOpenCandleTime[idx] = dt;
         Trades = Trades + 1;
         return (true);
      }
   }
  
   Alert("InvalidState");
   return (false);
}
//+------------------------------------------------------------------+
//| Delete order                                                     |
//+------------------------------------------------------------------+
bool DeleteTrade(int ticket)
{
   int idx;
   int count = ArraySize(TradeTicket);
   
   for (idx = 0; idx < count; idx++)
   {
      if (TradeTicket[idx] == ticket)
      {
         TradeTicket[idx] = EMPTY_VALUE;
         Trades = Trades - 1;
         return (true);
      }
   }

   return (false);
}
//+------------------------------------------------------------------+
//| Add Profit in Price element to history                           |
//+------------------------------------------------------------------+
void ProfitInPrice_Write(double value)
{
   ProfitInPriceHistory[ProfitInPricePosition] = ProfitInPrice;
   ProfitInPricePosition = (ProfitInPricePosition + 1) % ProfitInPriceHistoryLength;
}
//+------------------------------------------------------------------+
//| Get Profit in Price element from history                         |
//+------------------------------------------------------------------+
double ProfitInPrice_Read(int history_ticks)
{
   int Position = (ProfitInPricePosition - 1) - history_ticks;
   if (Position < 0)
   {
      Position += ProfitInPriceHistoryLength;
   }
   return (ProfitInPriceHistory[Position]);
}
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
{
   int idx;
//---- get indicator values
   double LowerBuffer = iCustom(NULL, 0, BANDS, BandsPeriod, BandsShift, BANDS_LO, 0);
   double UpperBuffer = iCustom(NULL, 0, BANDS, BandsPeriod, BandsShift, BANDS_HI, 0);
//----
   if (Volume[0] <= 1)
   {
      //--- new candle
      for (idx=0; idx < OrdersTotal(); idx++)
      {
         if (OrderSelect(idx, SELECT_BY_POS, MODE_TRADES) == false)
         {
            break;
         }
         if (OrderMagicNumber() != MAGIC)
         {
            continue;
         }

         //---- close orders opened more than MaxDuration candles
         datetime TradeOpenCandleTime = GetTradeOpenCandleTimeByTicket(OrderTicket());
         int __candles_ago = 0;
         for (__candles_ago = 0; __candles_ago < LKR_MaxDuration; __candles_ago++)
         {
            if (TradeOpenCandleTime == Time[__candles_ago])
            {
               break;
            }
         }
          
         if (__candles_ago == LKR_MaxDuration)
         {
            //---- order expired
            CloseSelectedOrder(White);
            continue;
         }
      }
   }
   else
   {
      //--- tick of existing candle
      for (idx=0; idx < OrdersTotal(); idx++)
      {
         if (OrderSelect(idx, SELECT_BY_POS, MODE_TRADES) == false)
         {
            break;
         }
         if (OrderMagicNumber() != MAGIC)
         {
            continue;
         }
         
         //---- assertion used on candle opening: Open = High = Low.
         if (High[0] > UpperBuffer)
         {
            CloseSelectedOrder(Lime);
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Function updates runtime parameters                              |
//+------------------------------------------------------------------+
void UpdateRuntimeParameters()
{
   int idx;
   double OverallCurrentChange = 0.0;

//---- only on new candle
   if (Volume[0] > 1)
   {
      return;
   }

//---- 
   for (idx=0; idx < OrdersTotal(); idx++)
   {
      if (OrderSelect(idx, SELECT_BY_POS, MODE_TRADES) == false)
      {
         break;
      }
      if (OrderMagicNumber() != MAGIC)
      {
         continue;
      }
      
      double CurrentChange = Close[0] - OrderOpenPrice();
      OverallCurrentChange += CurrentChange;
   }

//---- cawe parameter   
   if (OverallCurrentChange < -BCAWE)
   {
      cawe = 0;
   }
   else
   {
      cawe = 1;
   }
   
//---- pawe parameter
   ProfitInPrice_Write(ProfitInPrice);
   if (ProfitInPrice_Read(LKR_MaxDuration + LL3) - ProfitInPrice_Read(LKR_MaxDuration) > BAWE)
   {
      pawe = 0;
   }
   else
   {
      pawe = 1;
   }
}
//+------------------------------------------------------------------+
//| Write logfile                                                    |
//+------------------------------------------------------------------+
void WriteLogfile()
{
   if (LogFileHandle == 0)
   {
      LogFileHandle = FileOpen("runtime_log__bid_ask.csv", FILE_CSV|FILE_WRITE, ';');
   }
   
   if (LogFileHandle > 0)
   {
     FileWrite(LogFileHandle, Bid, Ask, Bid - Ask);
   }
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----
   CheckForOpen();
   UpdateRuntimeParameters();
   CheckForClose();
   WriteLogfile();
//----
   return(0);
}
//+------------------------------------------------------------------+