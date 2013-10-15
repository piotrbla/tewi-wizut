//+------------------------------------------------------------------+
//|         S4QAEURUSD -  breakout over maximum                      |
//|                                   Piotr B³aszyñski               |
//|                                   http://piotrbla.blogspot.com   |
//+------------------------------------------------------------------+
#property copyright "Piotr B³aszyñski"
#property link      "http://piotrbla.blogspot.com"

#include <stderror.mqh>
#include <stdlib.mqh>

extern double lots=0.1;
extern int    stop_loss=576;

extern int ma_period=81;
extern int paramAVolLength = 26;
extern int paramADuration = 16;
extern double paramABuffer = -0.00304;
extern int paramAVolThreshold = 100;


string comment="S4QAEURUSD";
string s;
int    magic=50612;

int init()
{
   if(lots<MarketInfo(Symbol(),MODE_MINLOT)) {
    lots=MarketInfo(Symbol(),MODE_MINLOT);
   }
   start();
   return(0);
}


bool CheckIsMarginEnough(int pCommand)
{
   if(AccountFreeMarginCheck(Symbol(), pCommand, lots)<=0 || GetLastError()==ERR_NOT_ENOUGH_MONEY) 
      return (false);
   return (true);
}

void SendCheckedBuyOrder(bool pUseFlag, int pMagic, double pStopLoss, double pTakeProfit, string pName)
{
   if(pUseFlag && countOrders(OP_BUY,pMagic)==0)
      if (CheckIsMarginEnough(OP_BUY))
         OrderSend(Symbol(), OP_BUY, lots, Ask, 0, pStopLoss, pTakeProfit, comment + " " + pName, pMagic);
}

void TransactionMaker()
{
   trail();
   double pHigh=High[iHighest(NULL,0,MODE_HIGH,ma_period,1)];
   double pLow=Low[iLowest(NULL,0,MODE_LOW,ma_period,1)];
   double pivot=(pHigh+pLow + Close[1])/3;
   //   if(cma>=pHigh && pHigh>=pma && countOrders(OP_BUY,magic)==0)
   //maxes(i) + paramABuffer <C(i,4) && volAverages(i)<paramAVolThreshold
   //if (pHigh + paramABuffer < Close[0] && countOrders(OP_BUY,magic)==0)
   if (pivot + paramABuffer < Close[0] && countOrders(OP_BUY,magic)==0)
   {
      if(IsTradeAllowed() && IsExpertEnabled() )
      {
         double tmpStopLossB = Bid-stop_loss*Point;
         double ttp1 = Bid+stop_loss*Point*500;
         SendCheckedBuyOrder(true, magic+1, tmpStopLossB, ttp1, "tp1");
         magic++;
      }
   }
}


bool IsProperOrderSymbol(int pNumber, int pPool)
{
   if(OrderSelect(pNumber, SELECT_BY_POS, pPool))
      if (OrderSymbol()==Symbol())
         return (true);
   return (false);
}

bool IsProperOrder(int pNumber, int pPool, int pMagic, int pType)
{
   if(IsProperOrderSymbol(pNumber, pPool))
      if (OrderMagicNumber()==pMagic && OrderType()==pType)
         return (true);
   return (false);
}

bool IsProperSystemOrder(int pNumber)
{
   if (IsProperOrderSymbol(pNumber, MODE_TRADES))
         return (true);
   return (false);
}

void trail()
{
   RefreshRates(); 
   double trailing_stop = 100;
   for(int i=0;i<OrdersTotal();i++)
   {
      if (IsProperSystemOrder(i))
      {
         double ts;
         bool   trail=false;
         if(OrderType()==OP_BUY)
         {
            int Bars_TM = iBarShift(NULL, PERIOD_H1, OrderOpenTime());
            ts=Bid-trailing_stop*Point;
            if (Bars_TM > paramADuration) 
            {
               trail=true;
               if(ts<OrderOpenPrice()) 
                  ts=Bid-(trailing_stop/2)*Point;
            }
            else 
               trail=false;  
            if(trail && OrderStopLoss()>ts)
               trail=false;
         }
         if(trail && OrderStopLoss()!=ts)
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,0))
               Print(ErrorDescription(GetLastError()));
      }
   }
}

int start() 
{

  s="\nS4QAEURUSD\n\n";
  TransactionMaker();
  Comment(s);
  return(0);
}


int deinit() {
   return(0);
}

int countOrders(int pType, int pMagic)
{
   int count=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if (IsProperOrder(i, MODE_TRADES, pMagic, pType))
         if(TimeToStr(OrderOpenTime(),TIME_DATE)==TimeToStr(TimeCurrent(),TIME_DATE))
            count++;  
   }   
   return(count);
}

