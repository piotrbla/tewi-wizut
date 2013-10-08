//+------------------------------------------------------------------+
//|                                            Bands_MinMax_Fast.mq4 |
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
extern int    BandsShift=2;
//---- buffers
double MovingBuffer[];
double UpperBuffer[];
double LowerBuffer[];
//---- 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("Bands_MinMax_Fast");
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MovingBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,UpperBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,LowerBuffer);
//----
   SetIndexDrawBegin(0,BandsPeriod);
   SetIndexDrawBegin(1,BandsPeriod);
   SetIndexDrawBegin(2,BandsPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Bollinger Bands MinMax                                           |
//+------------------------------------------------------------------+
int start()
{
//----
   int idx;
   double min, max;
//---- we don't have enough Bars
   if (Bars <= BandsPeriod + BandsShift)
   {
      return(0);
   }
//---- initial zero
   for (idx = 0; idx < BandsPeriod + BandsShift; idx++)
   {
      MovingBuffer[idx] = EMPTY_VALUE;
      UpperBuffer[idx] = EMPTY_VALUE;
      LowerBuffer[idx] = EMPTY_VALUE;
   }
//----
   //int limit = Bars - BandsPeriod;
   int limitpos;
   for (limitpos = 0; limitpos <= Bars - BandsPeriod - BandsShift; limitpos++)
   { 
      UpperBuffer[limitpos] = High[iHighest(NULL, 0, MODE_HIGH, 
         BandsPeriod, limitpos + BandsShift)];
      LowerBuffer[limitpos] = Low[iLowest(NULL, 0, MODE_LOW, 
         BandsPeriod, limitpos + BandsShift)];
   }
   return(0);
  }
//+-----------------------------------------------------------------+