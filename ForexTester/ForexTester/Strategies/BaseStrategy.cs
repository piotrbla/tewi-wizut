using System;
using System.Collections.Generic;
using System.Globalization;

namespace ForexTester.Strategies
{
    public class BaseStrategy
    {
        protected List<Candle> Candles;
        protected const string ResultFileExtension = "result";
        public BaseStrategy(List<Candle> candles)
        {
            Candles = candles;
        }

        protected IEnumerable<Candle> GetCandlesRange(int i, int length)
        {
            return Candles.GetRange(i - Math.Min(i - 1, length), Math.Min(i, length) + 1);
        }


        protected string GetDouble(double value)
        {
            return value.ToString("0.00000", CultureInfo.InvariantCulture);
        }
    }   
}