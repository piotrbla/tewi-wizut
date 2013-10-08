//+------------------------------------------------------------------+
//|                                                   TewiMiABCD.mq4 |
//|                                   Copyright 2013, Artur Pietrzyk |
//|                                            http://wi.zut.edu.pl/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Artur Pietrzyk"
#property link      "http://wi.zut.edu.pl/"
#define MAGIC 35494341

#define BANDS "Bands_MinMax_Fast"
#define BANDS_HI 1
#define BANDS_LO 2

#define VOLUME_MEAN "VolumeMean"
#define VOLUME_MEAN_M 0

//--- input parameters
extern double    SL=0.0060; 
extern double    TP=0.0020; 
extern int       MaxDuration=10;
extern double    B=-0.0009;
extern int       VolumeMeanThreshold=120;
extern int       VolumeMeanPeriod=4;
//+---+---+------+--------+
//| i | I | Test | Target | 
//+---+---+------+--------+
//| A | 0 | High | Above  |
//+---+---+------+--------+
//| B | 1 | High | Below  |
//+---+---+------+--------+
//| C | 2 | Low  | Above  |
//+---+---+------+--------+
//| D | 3 | Low  | Below  |
//+---+---+------+--------+
extern int       InvestmentDirection=0;
//--- bands configuration values
extern double    BandsPeriod=15;
extern int       BandsShift=2;

//--- variables
double   LastClose = 0;
double   LastOpen = 0;
int      PositionsInThatCandle = 0;

//---- trades buffer
int   TradeTicket[];
datetime   TradeOpenCandleTime[];
int   Trades=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   int TradeArraysSize = 256;
   ArrayResize(TradeTicket, TradeArraysSize);
   ArrayResize(TradeOpenCandleTime, TradeArraysSize);
   for (int idx = 0; idx < TradeArraysSize; idx++)
   {
      TradeTicket[idx] = EMPTY_VALUE;
   }
//---- because matlab working on current candle closing, 
//---- we need working on next candle opening
   MaxDuration++;
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
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
{
   int type, ticket;
   string comment;
//---- when this is new candle then reset counter
   if (Volume[0] <= 1)
   {
      PositionsInThatCandle = 0;
   }
//---- get indicator values
   double LowerBuffer = iCustom(NULL, 0, BANDS, BandsPeriod, BandsShift, BANDS_LO, 0);
   double UpperBuffer = iCustom(NULL, 0, BANDS, BandsPeriod, BandsShift, BANDS_HI, 0);
   double VolumeMean = iCustom(NULL, 0, VOLUME_MEAN, VolumeMeanPeriod, VOLUME_MEAN_M, 0);
//---- you will not open more orders
   if (PositionsInThatCandle > 0)
   {
      return;
   }

//---- volume filtering
   VolumeMean = - VolumeMean + Volume[0];
   if (InvestmentDirection == 1 && InvestmentDirection == 2)
   {
      // horizontal
      if (VolumeMean > VolumeMeanThreshold)
      {
         return;
      }
   }
   else if (InvestmentDirection == 0 && InvestmentDirection == 3)
   {
      // not horizontal
      if (VolumeMean < VolumeMeanThreshold)
      {
         return;
      }
   }
 
   //--- opening type 1 & 2.
   //--- assertion used on candle opening: Open = High = Low.
   if (InvestmentDirection < 2)
   {
      if (High[0] > UpperBuffer - B)
      {
         if (InvestmentDirection == 0)
         {
            type = OP_BUY;
            comment = "[TewiMiABCD] Opening type A, based on " + BANDS;
         }
         else if (InvestmentDirection == 1)
         {
            type = OP_SELL;
            comment = "[TewiMiABCD] Opening type B, based on " + BANDS;
         }
         
         ticket = EnterMarket(type, comment, Red);
         if (ticket < 0)
         {
            Print("OrderSend failed with error #", GetLastError());
            return(0);
         }
         PositionsInThatCandle++;
         AddTrade(ticket, Time[0]);
      }
   }
   else if (InvestmentDirection >= 2)
   {
      if (Low[0] < LowerBuffer - B)
      {
         if (InvestmentDirection == 2)
         {
            type = OP_BUY;
            comment = "[TewiMiABCD] Opening type C, based on " + BANDS;
         }
         else if (InvestmentDirection == 3)
         {
            type = OP_SELL;
            comment = "[TewiMiABCD] Opening type D, based on " + BANDS;
         }
      
         ticket = EnterMarket(type, comment, Blue);
         if (ticket < 0)
         {
            Print("OrderSend failed with error #", GetLastError());
            return(0);
         }
         PositionsInThatCandle++;
         AddTrade(ticket, Time[0]);
      }
   }
 
//----
   LastClose = Close[0];
//----
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
         for (__candles_ago = 0; __candles_ago < MaxDuration; __candles_ago++)
         {
            if (TradeOpenCandleTime == Time[__candles_ago])
            {
               break;
            }
         }
          
         if (__candles_ago == MaxDuration)
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
         
         //---- close orders in horizontal movements on open-inverse bands borders
         //---- assertion used on candle opening: Open = High = Low.
         if (InvestmentDirection == 1 && Low[0] < LowerBuffer)
         {
            CloseSelectedOrder(Green);
         }
         else if (InvestmentDirection == 2 && High[0] > UpperBuffer)
         {
            CloseSelectedOrder(Lime);
         }
      }
   }
//----
   LastOpen = Open[0];
//----
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----
   CheckForOpen();
   CheckForClose();
//----
   return(0);
}
//+------------------------------------------------------------------+