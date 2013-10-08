//+------------------------------------------------------------------+
//|                       TewiMiCOnePeriodOneParamSet__Automated.mq4 |
//|                                   Copyright 2013, Artur Pietrzyk |
//|                                            http://wi.zut.edu.pl/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Artur Pietrzyk"
#property link      "http://wi.zut.edu.pl/"
#define MAGIC 2858241

#define BANDS "Bands_MinMax_Fast"
#define BANDS_HI 1
#define BANDS_LO 2

#define VOLUME_MEAN "VolumeMean"
#define VOLUME_MEAN_M 0

//--- input parameters
double    B=-0.0009;
int       WSTP=20;
int       WSTK=3;
int       LKR_MaxDuration=10;
double    SL=0.0060;  
double    TP=0.0020; 
int       OP_MaxOpenPositions=2;
int       BVOL_VolumeMeanThreshold=120;
int       VWST_VolumeMeanPeriod=4;
int       LL3=10;
double    BAWE=0.0011;
double    BCAWE=0.0019;

//--- variables
int      cawe = 1;
int      pawe = 1;
int      LogFileHandle[];
int      candle = 0;

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
void process_arguments()
{ 
//--- convert arguments from matlab to metatrader
   WSTP--;
   WSTK--;
   
//--- calculate configuration values
   BandsPeriod = WSTP - WSTK;
   BandsShift = WSTK;

//---- because matlab working on current candle closing, 
//---- we need working on next candle opening
   LKR_MaxDuration++;
}
int init()
{
   process_arguments();
   
//--- init log file
   ArrayResize(LogFileHandle, 256);
   
//--- init profit in price buffer
   ProfitInPriceHistoryLength = 256;
   if (LL3 >= ProfitInPriceHistoryLength)
   {
      //ProfitInPriceHistoryLength = LL3 * 2;
      Alert("No way....");
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
//---- you will not open more orders
   if (OpenedOrdersCount() >= OP_MaxOpenPositions)
   {
      return;
   }
   
//---- get indicator values
   double LowerBuffer = iCustom(NULL, 0, BANDS, BandsPeriod, BandsShift, BANDS_LO, 0);
   double UpperBuffer = iCustom(NULL, 0, BANDS, BandsPeriod, BandsShift, BANDS_HI, 0);
   double VolumeMean = iCustom(NULL, 0, VOLUME_MEAN, VWST_VolumeMeanPeriod, VOLUME_MEAN_M, 0);

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
      comment = "[TewiMiCOnePeriodOneParamSet__Automated] Opening type C, based on " + BANDS;
      
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
void WriteLogfile(int IDX, int POCZ)
{
   if (LogFileHandle[IDX] == 0)
   {
      LogFileHandle[IDX] = FileOpen(POCZ + "_runtime_log__bid_ask.csv", FILE_CSV|FILE_WRITE, ';');
   }
   
   if (LogFileHandle[IDX] > 0)
   {
     FileWrite(LogFileHandle[IDX], Bid, Ask, Bid - Ask);
   }
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//---- only on new candle
   if (Volume[0] <= 1)
   {
      candle++;
   }

   int POCZ, IDX;
//--- BOTTOM CODER BEGIN
if (candle >= 4300 && candle < 4300+100)
{
POCZ = 4300;
IDX = 33;
B = -0.0008;
WSTP = 20;
WSTK = 2;
LKR_MaxDuration = 47;
SL = 0.0088;
TP = 0.0016;
OP_MaxOpenPositions = 7;
BVOL_VolumeMeanThreshold = 263;
VWST_VolumeMeanPeriod = 5;
LL3 = 13;
BAWE = 0.0014;
BCAWE = 0.0028;
process_arguments();
}
else if (candle >= 4200 && candle < 4200+100)
{
POCZ = 4200;
IDX = 32;
B = -0.00012;
WSTP = 17;
WSTK = 4;
LKR_MaxDuration = 48;
SL = 0.0086;
TP = 0.004;
OP_MaxOpenPositions = 9;
BVOL_VolumeMeanThreshold = 173;
VWST_VolumeMeanPeriod = 6;
LL3 = 13;
BAWE = 0.00139;
BCAWE = 0.00196;
process_arguments();
}
else if (candle >= 4100 && candle < 4100+100)
{
POCZ = 4100;
IDX = 31;
B = -0.0002;
WSTP = 20;
WSTK = 2;
LKR_MaxDuration = 36;
SL = 0.004;
TP = 0.0016;
OP_MaxOpenPositions = 8;
BVOL_VolumeMeanThreshold = 197;
VWST_VolumeMeanPeriod = 8;
LL3 = 7;
BAWE = 0.0013;
BCAWE = 0.003;
process_arguments();
}
else if (candle >= 4000 && candle < 4000+100)
{
POCZ = 4000;
IDX = 30;
B = -0.00059;
WSTP = 21;
WSTK = 2;
LKR_MaxDuration = 16;
SL = 0.008;
TP = 0.0016;
OP_MaxOpenPositions = 9;
BVOL_VolumeMeanThreshold = 160;
VWST_VolumeMeanPeriod = 7;
LL3 = 15;
BAWE = 0.00125;
BCAWE = 0.00181;
process_arguments();
}
else if (candle >= 3900 && candle < 3900+100)
{
POCZ = 3900;
IDX = 29;
B = -0.0001;
WSTP = 20;
WSTK = 1;
LKR_MaxDuration = 31;
SL = 0.0052;
TP = 0.002;
OP_MaxOpenPositions = 6;
BVOL_VolumeMeanThreshold = 192;
VWST_VolumeMeanPeriod = 8;
LL3 = 7;
BAWE = 0.0017;
BCAWE = 0.0008;
process_arguments();
}
else if (candle >= 3800 && candle < 3800+100)
{
POCZ = 3800;
IDX = 28;
B = -0.00033;
WSTP = 19;
WSTK = 3;
LKR_MaxDuration = 17;
SL = 0.0062;
TP = 0.0018;
OP_MaxOpenPositions = 10;
BVOL_VolumeMeanThreshold = 173;
VWST_VolumeMeanPeriod = 6;
LL3 = 11;
BAWE = 0.00172;
BCAWE = 0.00127;
process_arguments();
}
else if (candle >= 3700 && candle < 3700+100)
{
POCZ = 3700;
IDX = 27;
B = -0.00071;
WSTP = 18;
WSTK = 1;
LKR_MaxDuration = 20;
SL = 0.0086;
TP = 0.0084;
OP_MaxOpenPositions = 6;
BVOL_VolumeMeanThreshold = 168;
VWST_VolumeMeanPeriod = 6;
LL3 = 9;
BAWE = 0.00178;
BCAWE = 0.00282;
process_arguments();
}
else if (candle >= 3600 && candle < 3600+100)
{
POCZ = 3600;
IDX = 26;
B = -0.00017;
WSTP = 19;
WSTK = 5;
LKR_MaxDuration = 16;
SL = 0.0074;
TP = 0.006;
OP_MaxOpenPositions = 11;
BVOL_VolumeMeanThreshold = 199;
VWST_VolumeMeanPeriod = 6;
LL3 = 11;
BAWE = 0.00115;
BCAWE = 0.00174;
process_arguments();
}
else if (candle >= 3500 && candle < 3500+100)
{
POCZ = 3500;
IDX = 25;
B = -0.0002;
WSTP = 19;
WSTK = 1;
LKR_MaxDuration = 22;
SL = 0.0092;
TP = 0.002;
OP_MaxOpenPositions = 6;
BVOL_VolumeMeanThreshold = 119;
VWST_VolumeMeanPeriod = 6;
LL3 = 14;
BAWE = 0.0017;
BCAWE = 0.0014;
process_arguments();
}
else if (candle >= 3400 && candle < 3400+100)
{
POCZ = 3400;
IDX = 24;
B = -0.00018;
WSTP = 20;
WSTK = 1;
LKR_MaxDuration = 20;
SL = 0.0062;
TP = 0.0086;
OP_MaxOpenPositions = 9;
BVOL_VolumeMeanThreshold = 181;
VWST_VolumeMeanPeriod = 7;
LL3 = 10;
BAWE = 0.00134;
BCAWE = 0.00201;
process_arguments();
}
else if (candle >= 3300 && candle < 3300+100)
{
POCZ = 3300;
IDX = 23;
B = -0.00116;
WSTP = 20;
WSTK = 2;
LKR_MaxDuration = 19;
SL = 0.006;
TP = 0.0092;
OP_MaxOpenPositions = 10;
BVOL_VolumeMeanThreshold = 254;
VWST_VolumeMeanPeriod = 5;
LL3 = 11;
BAWE = 0.00153;
BCAWE = 0.00082;
process_arguments();
}
else if (candle >= 3200 && candle < 3200+100)
{
POCZ = 3200;
IDX = 22;
B = -0.00187;
WSTP = 18;
WSTK = 4;
LKR_MaxDuration = 35;
SL = 0.0022;
TP = 0.0084;
OP_MaxOpenPositions = 10;
BVOL_VolumeMeanThreshold = 256;
VWST_VolumeMeanPeriod = 6;
LL3 = 9;
BAWE = 0.0013;
BCAWE = 0.00253;
process_arguments();
}
else if (candle >= 3100 && candle < 3100+100)
{
POCZ = 3100;
IDX = 21;
B = -0.00119;
WSTP = 19;
WSTK = 2;
LKR_MaxDuration = 21;
SL = 0.0028;
TP = 0.006;
OP_MaxOpenPositions = 10;
BVOL_VolumeMeanThreshold = 155;
VWST_VolumeMeanPeriod = 5;
LL3 = 8;
BAWE = 0.00122;
BCAWE = 0.00161;
process_arguments();
}
else if (candle >= 3000 && candle < 3000+100)
{
POCZ = 3000;
IDX = 20;
B = -0.00185;
WSTP = 18;
WSTK = 5;
LKR_MaxDuration = 22;
SL = 0.0018;
TP = 0.0082;
OP_MaxOpenPositions = 11;
BVOL_VolumeMeanThreshold = 185;
VWST_VolumeMeanPeriod = 8;
LL3 = 7;
BAWE = 0.00127;
BCAWE = 0.00171;
process_arguments();
}
else if (candle >= 2900 && candle < 2900+100)
{
POCZ = 2900;
IDX = 19;
B = -0.00052;
WSTP = 19;
WSTK = 2;
LKR_MaxDuration = 23;
SL = 0.0032;
TP = 0.0084;
OP_MaxOpenPositions = 9;
BVOL_VolumeMeanThreshold = 165;
VWST_VolumeMeanPeriod = 6;
LL3 = 11;
BAWE = 0.00145;
BCAWE = 0.00079;
process_arguments();
}
else if (candle >= 2800 && candle < 2800+100)
{
POCZ = 2800;
IDX = 18;
B = -0.0012;
WSTP = 19;
WSTK = 2;
LKR_MaxDuration = 21;
SL = 0.0038;
TP = 0.0096;
OP_MaxOpenPositions = 9;
BVOL_VolumeMeanThreshold = 185;
VWST_VolumeMeanPeriod = 7;
LL3 = 14;
BAWE = 0.00131;
BCAWE = 0.00087;
process_arguments();
}
else if (candle >= 2700 && candle < 2700+100)
{
POCZ = 2700;
IDX = 17;
B = -0.0012;
WSTP = 19;
WSTK = 2;
LKR_MaxDuration = 37;
SL = 0.0046;
TP = 0.0063;
OP_MaxOpenPositions = 8;
BVOL_VolumeMeanThreshold = 202;
VWST_VolumeMeanPeriod = 6;
LL3 = 5;
BAWE = 0.002;
BCAWE = 0.0013;
process_arguments();
}
else if (candle >= 2600 && candle < 2600+100)
{
POCZ = 2600;
IDX = 16;
B = -0.0005;
WSTP = 19;
WSTK = 2;
LKR_MaxDuration = 32;
SL = 0.0034;
TP = 0.0075;
OP_MaxOpenPositions = 9;
BVOL_VolumeMeanThreshold = 260;
VWST_VolumeMeanPeriod = 8;
LL3 = 15;
BAWE = 0.0011;
BCAWE = 0.0008;
process_arguments();
}
else if (candle >= 2500 && candle < 2500+100)
{
POCZ = 2500;
IDX = 15;
B = -0.00125;
WSTP = 19;
WSTK = 4;
LKR_MaxDuration = 30;
SL = 0.007;
TP = 0.0076;
OP_MaxOpenPositions = 7;
BVOL_VolumeMeanThreshold = 199;
VWST_VolumeMeanPeriod = 8;
LL3 = 6;
BAWE = 0.00118;
BCAWE = 0.00086;
process_arguments();
}
else if (candle >= 2400 && candle < 2400+100)
{
POCZ = 2400;
IDX = 14;
B = -0.0005;
WSTP = 18;
WSTK = 1;
LKR_MaxDuration = 32;
SL = 0.0034;
TP = 0.0064;
OP_MaxOpenPositions = 7;
BVOL_VolumeMeanThreshold = 213;
VWST_VolumeMeanPeriod = 7;
LL3 = 8;
BAWE = 0.0011;
BCAWE = 0.0009;
process_arguments();
}
else if (candle >= 2300 && candle < 2300+100)
{
POCZ = 2300;
IDX = 13;
B = -0.00196;
WSTP = 19;
WSTK = 2;
LKR_MaxDuration = 25;
SL = 0.007;
TP = 0.0066;
OP_MaxOpenPositions = 8;
BVOL_VolumeMeanThreshold = 172;
VWST_VolumeMeanPeriod = 8;
LL3 = 11;
BAWE = 0.00102;
BCAWE = 0.00063;
process_arguments();
}
else if (candle >= 2200 && candle < 2200+100)
{
POCZ = 2200;
IDX = 12;
B = -0.00053;
WSTP = 19;
WSTK = 5;
LKR_MaxDuration = 22;
SL = 0.0036;
TP = 0.0074;
OP_MaxOpenPositions = 9;
BVOL_VolumeMeanThreshold = 155;
VWST_VolumeMeanPeriod = 8;
LL3 = 13;
BAWE = 0.00128;
BCAWE = 0.00132;
process_arguments();
}
else if (candle >= 2100 && candle < 2100+100)
{
POCZ = 2100;
IDX = 11;
B = -0.00012;
WSTP = 19;
WSTK = 3;
LKR_MaxDuration = 23;
SL = 0.003;
TP = 0.007;
OP_MaxOpenPositions = 6;
BVOL_VolumeMeanThreshold = 207;
VWST_VolumeMeanPeriod = 7;
LL3 = 10;
BAWE = 0.00125;
BCAWE = 0.00116;
process_arguments();
}
else if (candle >= 2000 && candle < 2000+100)
{
POCZ = 2000;
IDX = 10;
B = -0.0005;
WSTP = 19;
WSTK = 3;
LKR_MaxDuration = 32;
SL = 0.0032;
TP = 0.0073;
OP_MaxOpenPositions = 9;
BVOL_VolumeMeanThreshold = 217;
VWST_VolumeMeanPeriod = 6;
LL3 = 6;
BAWE = 0.0016;
BCAWE = 0.0011;
process_arguments();
}
else if (candle >= 1900 && candle < 1900+100)
{
POCZ = 1900;
IDX = 9;
B = -0.0003;
WSTP = 21;
WSTK = 2;
LKR_MaxDuration = 24;
SL = 0.0086;
TP = 0.0092;
OP_MaxOpenPositions = 7;
BVOL_VolumeMeanThreshold = 208;
VWST_VolumeMeanPeriod = 6;
LL3 = 5;
BAWE = 0.0018;
BCAWE = 0.0009;
process_arguments();
}
else if (candle >= 1800 && candle < 1800+100)
{
POCZ = 1800;
IDX = 8;
B = -0.00011;
WSTP = 19;
WSTK = 3;
LKR_MaxDuration = 23;
SL = 0.0034;
TP = 0.0056;
OP_MaxOpenPositions = 8;
BVOL_VolumeMeanThreshold = 236;
VWST_VolumeMeanPeriod = 7;
LL3 = 7;
BAWE = 0.0016;
BCAWE = 0.00104;
process_arguments();
}
else if (candle >= 1700 && candle < 1700+100)
{
POCZ = 1700;
IDX = 7;
B = -0.00011;
WSTP = 21;
WSTK = 2;
LKR_MaxDuration = 16;
SL = 0.008;
TP = 0.005;
OP_MaxOpenPositions = 9;
BVOL_VolumeMeanThreshold = 202;
VWST_VolumeMeanPeriod = 5;
LL3 = 10;
BAWE = 0.00152;
BCAWE = 0.00151;
process_arguments();
}
else if (candle >= 1600 && candle < 1600+100)
{
POCZ = 1600;
IDX = 6;
B = -0.00027;
WSTP = 23;
WSTK = 3;
LKR_MaxDuration = 19;
SL = 0.0068;
TP = 0.0046;
OP_MaxOpenPositions = 7;
BVOL_VolumeMeanThreshold = 230;
VWST_VolumeMeanPeriod = 4;
LL3 = 9;
BAWE = 0.00163;
BCAWE = 0.00222;
process_arguments();
}
else if (candle >= 1500 && candle < 1500+100)
{
POCZ = 1500;
IDX = 5;
B = -0.0003;
WSTP = 20;
WSTK = 1;
LKR_MaxDuration = 25;
SL = 0.0036;
TP = 0.007;
OP_MaxOpenPositions = 11;
BVOL_VolumeMeanThreshold = 249;
VWST_VolumeMeanPeriod = 7;
LL3 = 15;
BAWE = 0.0012;
BCAWE = 0.0012;
process_arguments();
}
else if (candle >= 1400 && candle < 1400+100)
{
POCZ = 1400;
IDX = 4;
B = -0.0008;
WSTP = 21;
WSTK = 1;
LKR_MaxDuration = 30;
SL = 0.0036;
TP = 0.003;
OP_MaxOpenPositions = 10;
BVOL_VolumeMeanThreshold = 247;
VWST_VolumeMeanPeriod = 8;
LL3 = 15;
BAWE = 0.0015;
BCAWE = 0.0021;
process_arguments();
}
else if (candle >= 1300 && candle < 1300+100)
{
POCZ = 1300;
IDX = 3;
B = -0.0001;
WSTP = 21;
WSTK = 1;
LKR_MaxDuration = 23;
SL = 0.0036;
TP = 0.006;
OP_MaxOpenPositions = 6;
BVOL_VolumeMeanThreshold = 135;
VWST_VolumeMeanPeriod = 8;
LL3 = 7;
BAWE = 0.0016;
BCAWE = 0.0018;
process_arguments();
}
else if (candle >= 1200 && candle < 1200+100)
{
POCZ = 1200;
IDX = 2;
B = -0.00101;
WSTP = 23;
WSTK = 6;
LKR_MaxDuration = 45;
SL = 0.0084;
TP = 0.0094;
OP_MaxOpenPositions = 11;
BVOL_VolumeMeanThreshold = 155;
VWST_VolumeMeanPeriod = 9;
LL3 = 10;
BAWE = 0.00133;
BCAWE = 0.00141;
process_arguments();
}
else if (candle >= 1100 && candle < 1100+100)
{
POCZ = 1100;
IDX = 1;
B = -0.00014;
WSTP = 23;
WSTK = 4;
LKR_MaxDuration = 20;
SL = 0.0062;
TP = 0.0096;
OP_MaxOpenPositions = 8;
BVOL_VolumeMeanThreshold = 242;
VWST_VolumeMeanPeriod = 6;
LL3 = 11;
BAWE = 0.0016;
BCAWE = 0.00207;
process_arguments();
}
else if (candle >= 1000 && candle < 1000+100)
{
POCZ = 1000;
IDX = 0;
B = -0.0009;
WSTP = 20;
WSTK = 3;
LKR_MaxDuration = 34;
SL = 0.005;
TP = 0.0059;
OP_MaxOpenPositions = 7;
BVOL_VolumeMeanThreshold = 153;
VWST_VolumeMeanPeriod = 7;
LL3 = 15;
BAWE = 0.0011;
BCAWE = 0.0019;
process_arguments();
}
else
{
return(0);
}


//---- BOTTOM CODER ENDS
   CheckForOpen();
   UpdateRuntimeParameters();
   CheckForClose();
   WriteLogfile(IDX, POCZ);
//----
   return(0);
}
//+------------------------------------------------------------------+