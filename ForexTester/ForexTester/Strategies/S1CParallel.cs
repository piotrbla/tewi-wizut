using System.Collections.Generic;

namespace ForexTester.Strategies
{
    class S1CParallel : S1Parallel
    {
        public S1CParallel(List<Candle> candles)
            : base(candles)
        {
        }

        protected override bool ComputePredicate(double mean, double close)
        {
            return mean > close;
        }

        protected override double ComputeProfit(int i)
        {
            return Candles[i + 1].Close - Candles[i + 1].Open;
        }

        protected override string ResultFilename{get { return "texRc.txt"; }}
    }
}
