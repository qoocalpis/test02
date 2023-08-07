//+------------------------------------------------------------------+
//|                                          Custom_Price_Action.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"


enum ENUM_CANDLESTICK
  {
   BULLISH_CANDLE,
   BEARISH_CANDLE,
   DOJI_CANDLE
  };

enum ENUM_CHART_PATTERN
  {
   SPIKE_HIGH,
   SPIKE_LOW,
   REVERSAL_HIGH,
   REVERSAL_LOW,
   NONE
  };
//+------------------------------------------------------------------+
//|function PriceAction
//+------------------------------------------------------------------+
int PriceActionTrigger(ENUM_TIMEFRAMES time_frame, int target, MqlRates &bar[])
  {

//bar[0]は最新から一本前のローソク足の情報
   if(target > 0 && (CheckSpikeHighLow(bar, target) == SPIKE_LOW || CheckReversalHighLow(bar, target) == REVERSAL_LOW))
      return 1;
   if(target < 0 && (CheckSpikeHighLow(bar, target) == SPIKE_HIGH || CheckReversalHighLow(bar, target) == REVERSAL_HIGH))
      return -1;

   return 0;
  }

//+------------------------------------------------------------------+
//|GetTypeOfCandle function
//+------------------------------------------------------------------+
ENUM_CANDLESTICK GetTypeOfCandle(MqlRates &bar)
  {
   if(bar.open-bar.close<0)
      return BULLISH_CANDLE;
   if(bar.open-bar.close>0)
      return BEARISH_CANDLE;
   return DOJI_CANDLE;
  }

//+------------------------------------------------------------------+
//|PriceRange function
//+------------------------------------------------------------------+
double PriceRange(MqlRates &bar)
  {
   return MathAbs(bar.open - bar.close);
  }

//+------------------------------------------------------------------+
//|PinbarCheck function
//+------------------------------------------------------------------+
ENUM_CHART_PATTERN CheckSpikeHighLow(MqlRates &bar[], int target)
  {

   double minOpenClose = MathMin(bar[0].open,bar[0].close);
   double maxOpenClose = MathMax(bar[0].open,bar[0].close);
   double upperWick = bar[0].high - maxOpenClose;
   double lowerWick = minOpenClose - bar[0].low;
   double upperWick_1 = bar[1].high - MathMax(bar[1].open,bar[1].close);
   double lowerWick_1 = MathMin(bar[1].open,bar[1].close) - bar[1].low;
   double upperWick_2 = bar[2].high - MathMax(bar[2].open,bar[2].close);
   double lowerWick_2 = MathMin(bar[2].open,bar[2].close) - bar[2].low;


   if(target>0
      && lowerWick>(bar[0].high-minOpenClose)*3
      && bar[2].low>=bar[1].low
      && bar[1].low>=bar[0].close
      && upperWick_2<(MathMax(bar[2].open,bar[2].close)-bar[2].low)
      && PriceRange(bar[1])<(bar[0].high-bar[0].low)*2.5)
     {
      Print("スパイクロー出現!!");
      return SPIKE_LOW;
     }
   if(target<0
      && upperWick>(maxOpenClose-bar[0].low)*3
      && bar[2].high<=bar[1].high
      && bar[1].high<=bar[0].high
      && lowerWick_2<(MathMax(bar[2].open,bar[2].close)-bar[2].low)
      && PriceRange(bar[1])<(bar[0].high-bar[0].low)*2.5)
     {
      Print("スパイクハイ出現!!");
      return SPIKE_HIGH;
     }
   return NONE;
  }

//+------------------------------------------------------------------+
//|CheckReversal function
//+------------------------------------------------------------------+
ENUM_CHART_PATTERN CheckReversalHighLow(MqlRates &bar[], int target)
  {

   double upperWick = bar[0].high - MathMax(bar[0].open,bar[0].close);
   double lowerWick = MathMin(bar[0].open,bar[0].close) - bar[0].low;
   double upperWick_1 = bar[1].high - MathMax(bar[1].open,bar[1].close);
   double lowerWick_1 = MathMin(bar[1].open,bar[1].close) - bar[1].low;
   double upperWick_2 = bar[2].high - MathMax(bar[2].open,bar[2].close);
   double lowerWick_2 = MathMin(bar[2].open,bar[2].close) - bar[2].low;


   if(target>0
      && upperWick<lowerWick
      && PriceRange(bar[1])*3>PriceRange(bar[0])
      && upperWick_2<(MathMax(bar[2].open,bar[2].close)-bar[2].low)
      && ((GetTypeOfCandle(bar[1])==BEARISH_CANDLE
           && bar[1].low>bar[0].low
           && bar[0].low<MathMin(bar[2].open,bar[2].close)
           && bar[1].high<bar[0].high
           && bar[1].open<bar[0].close)
          ||
          (GetTypeOfCandle(bar[1])==BULLISH_CANDLE
           && bar[2].low>bar[0].low
           && bar[0].low<bar[1].low
           && bar[2].high<bar[0].high
           && bar[0].high>bar[1].high
           && bar[1].close<bar[0].close)))
     {
      Print("リバーサルロー出現!!");
      return REVERSAL_LOW;
     }

   if(target<0
      && upperWick>lowerWick
      && PriceRange(bar[1])*3>PriceRange(bar[0])
      && lowerWick_2<(MathMax(bar[2].open,bar[2].close)-bar[2].low)
      && ((GetTypeOfCandle(bar[1])==BULLISH_CANDLE
           && bar[1].low>bar[0].low
           && bar[1].high<bar[0].high
           && bar[0].high>MathMax(bar[2].open,bar[2].close)
           && bar[1].open>bar[0].close)
          ||
          (GetTypeOfCandle(bar[1])==BEARISH_CANDLE
           && bar[2].low>bar[0].low
           && bar[0].low<bar[1].low
           && bar[2].high<bar[0].high
           && bar[0].high>bar[1].high
           && bar[1].close>bar[0].close)))
     {
      Print("リバーサルハイ出現!!");
      return REVERSAL_HIGH;
     }

   return NONE;
  }
//+------------------------------------------------------------------+
