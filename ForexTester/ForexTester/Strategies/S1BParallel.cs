﻿using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace ForexTester.Strategies
{
    class S1BParallel : S1Parallel
    {
        public S1BParallel(List<Candle> candles)
            : base(candles)
        {
        }

        protected override bool ComputePredicate(double mean, double close)
        {
            return mean < close;
        }

        protected override double ComputeProfit(int i)
        {
            return -Candles[i + 1].Close + Candles[i + 1].Open;
        }

        protected override string ResultFilename{get { return "texRb.txt"; }}
    }
}
