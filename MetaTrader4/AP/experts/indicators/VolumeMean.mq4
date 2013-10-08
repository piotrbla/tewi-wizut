//+------------------------------------------------------------------+
//|                                                   VolumeMean.mq4 |
//|                                 Copyright © 2013, Artur Pietrzyk |
//|                                            http://wi.zut.edu.pl/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Artur Pietrzyk"
#property link      "http://wi.zut.edu.pl/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
extern int    MeanPeriod=5;
//---- buffers
double MeanBuffer[];
//---- 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("VolumeMean");
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MeanBuffer);
//----
   SetIndexDrawBegin(0,MeanPeriod);
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
//---- we don't have enough Bars
   if (Bars <= MeanPeriod)
   {
      return(0);
   }
//---- initial zero
   for (idx = 0; idx < MeanPeriod; idx++)
   {
      MeanBuffer[idx] = EMPTY_VALUE;
   }
//----
   int limitpos;
   for (limitpos = 0; limitpos <= Bars - MeanPeriod; limitpos++)
   { 
      double itemsSum = 0;
      int itemsCount = 0;
      
      for (idx = limitpos; idx < limitpos + MeanPeriod; idx++)
      {
         itemsSum += Volume[idx];
         itemsCount++;
      }
      
      MeanBuffer[limitpos] = itemsSum / itemsCount;
   }
   return(0);
  }
//+-----------------------------------------------------------------+