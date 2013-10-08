//+------------------------------------------------------------------+
//|                                                   Bands_Fast.mq4 |
//|                                 Copyright © 2013, Artur Pietrzyk |
//|                                            http://wi.zut.edu.pl/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Artur Pietrzyk"
#property link      "http://wi.zut.edu.pl/"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 LightSeaGreen
#property indicator_color2 LightSeaGreen
#property indicator_color3 LightSeaGreen
//---- indicator parameters
extern int    BandsPeriod=15;
extern int    MAPeriod=12;
extern int    BandsShift=0;
extern double BandsDeviations=1.8;
//---- buffers
double MovingBuffer[];
double UpperBuffer[];
double LowerBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("Bands_Fast");
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MovingBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,UpperBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,LowerBuffer);
//----
   SetIndexDrawBegin(0,BandsPeriod+BandsShift);
   SetIndexDrawBegin(1,BandsPeriod+BandsShift);
   SetIndexDrawBegin(2,BandsPeriod+BandsShift);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
//+------------------------------------------------------------------+
int start()
{
//----
   int i;
   int k;
   int j;
   double deviation;
   double sum,oldval,newres;
//---- we don't have enough Bars
   if (Bars <= BandsPeriod)
   {
      return(0);
   }
//---- initial zero
   for (i=1; i < BandsPeriod; i++)
   {
      MovingBuffer[i] = EMPTY_VALUE;
      UpperBuffer[i] = EMPTY_VALUE;
      LowerBuffer[i] = EMPTY_VALUE;
   }
//----
   int limit = Bars - MAPeriod;
   
   for (i=0; i < limit - MAPeriod; i++)
   {
      double suma = 0;
      // that don't fits mean calculated by matlab
      //MovingBuffer[i] = iMA(NULL,0,MAPeriod,BandsShift,MODE_SMA,PRICE_CLOSE,i);
      for (j = i + MAPeriod; j > i; j--)
      {
        suma += Close[j];
      }
      MovingBuffer[i] = suma/MAPeriod;
   }
//----
   i = Bars - BandsPeriod + 1;

   while (i >= 0)
   {
      sum = 0.0;

      // that don't fits mean calculated by matlab
      //oldval=MovingBuffer[i];
      
      /*
       * Calculate mean
       */
      k = i + BandsPeriod + 1;
      oldval = 0;
      while (k > i)
      {
         oldval += Close[k];
         k--;
      }
      oldval /= BandsPeriod + 1;
      
      /*
       * Calculate std
       */
      k = i + BandsPeriod + 1;
      while (k > i)
      {
         newres=Close[k]-oldval;
         sum+=newres*newres;
         k--;
      }
      
      deviation = BandsDeviations * MathSqrt(sum/BandsPeriod);
      UpperBuffer[i] = MovingBuffer[i] + deviation;
      LowerBuffer[i] = MovingBuffer[i] - deviation;
      i--;
   }
   return(0);
  }
//+------------------------------------------------------------------+