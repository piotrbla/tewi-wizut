using System.Collections.Generic;
using System.IO;

namespace ForexTester.Strategies
{
    class EarthWorm : BaseStrategy
    {
        List<double> sumRa;
        enum TransactionStates
        {
            None,
            Short,
            Long
        }
        public EarthWorm(List<Candle> candles)
            : base(candles)
        {
        }
        public List<double> GetSumReturns()
        {
            return sumRa;
        }

        public void ComputeStrategy(object selectedItem)
        {
            var filename = selectedItem + "." + ResultFileExtension;
            var bestReturn = -120.0;
            var candlesCount = Candles.Count;
            var bestCalmar = 0.0;
            var bestParam1 = 0;
            var bestParam2 = 0;
            var shortPositionOpen = 0;
            var longPositionOpen = 0;
            const double defaultSpread = 0.0002;
            using (var writer = new StreamWriter(filename, false))
            {
                writer.WriteLine("results");
                //const int param1 = 215;
                for (var param1 = 10; param1 <= 80; param1 += 1)
                {
                   // const int param2 = 3;
                    for (var param2 = 1; param2 <= 40; param2++)
                        //for (var param2 = 1; param2 <= param1 / 2 + 1; param2++)
                    {
                        var transactionState = TransactionStates.None;
                        var candlesBegin = param1 + 1;
                        var kon = candlesCount - 1;
                        var lastCandle = kon;
                        var isPosition = false;
                        sumRa = new List<double>(candlesCount);
                        var returnValues = new List<double>(candlesCount);
                        var drawdowns = new List<double>(candlesCount);
                        for (var i = 0; i < candlesBegin; i++)
                        {
                            sumRa.Add(0);
                            returnValues.Add(0);
                        }
                        for (var i = candlesBegin; i < lastCandle; i++)
                        {
                            var downCandlesCount = 0;
                            var positionReturn = 0D;
                            for (var j = i - param1; j <= i - 1; j++)
                            {
                                if (Candles[j].Close > Candles[j + 1].Close)
                                    downCandlesCount++;
                            }
                            double spread;
                            if (downCandlesCount > param1/2 + param2)
                            {
                                spread = transactionState == TransactionStates.Short ? 0 : defaultSpread;
                                shortPositionOpen++;
                                positionReturn = Candles[i].Close - Candles[i + 1].Close - spread;
                                transactionState = TransactionStates.Short;
                                isPosition = true;
                                writer.WriteLine("OTWARCIE Short: \t\t '{0} {1}'\t{2}\t{3}", Candles[i].Date, Candles[i].Time, GetDouble(positionReturn), GetDouble(Candles[i].Close));

                            }
                            if (downCandlesCount < param1/2 - param2)
                            {
                                spread = transactionState == TransactionStates.Long ? 0 : defaultSpread;
                                longPositionOpen++;
                                positionReturn = -Candles[i].Close + Candles[i + 1].Close - spread;
                                transactionState = TransactionStates.Long;
                                isPosition = true;
                                writer.WriteLine("OTWARCIE  LONG: \t\t '{0} {1}'\t{2}\t{3}", Candles[i].Date, Candles[i].Time, GetDouble(positionReturn), GetDouble(Candles[i].Close));
                            }
                            returnValues.Add(positionReturn);
                            sumRa.Add(sumRa[i - 1] + returnValues[i]); //krzywa narastania kapitału

                        }

                        var recordReturn = 0.0; //rekord zysku
                        var recordDrawdown = 0.0; //rekord obsuniecia
                        for (var j = 0; j < lastCandle; j++)
                        {
                            if (sumRa[j] > recordReturn)
                            {
                                recordReturn = sumRa[j];
                            }
                            drawdowns.Add(sumRa[j] - recordReturn);
                                //róznica pomiedzy bieżącą wartoscia kapitału skumulowanego a dotychczasowym rekordem
                            if (drawdowns[j] < recordDrawdown)
                                recordDrawdown = drawdowns[j]; //obsuniecie maksymalne
                        }

                        //wyniki końcowe
                        var sumReturn = sumRa[lastCandle - 1];
                        var calmar = -sumReturn/recordDrawdown; //wskaznik Calmara
                        if (bestReturn < sumReturn)
                        {
                            bestReturn = sumReturn;
                            bestCalmar = calmar;
                            bestParam1 = param1;
                            bestParam2 = param2;
                            writer.WriteLine("{0}\t{1}\t{2}\t{3}",
                                                GetDouble(sumReturn), GetDouble(param1), GetDouble(param2),
                                                GetDouble(calmar));
                        }
                    }
                }
            }
            using (var writer = new StreamWriter(filename, true))
            {
                writer.WriteLine("{0}\t{1}\t{2}\t{3}",
                        GetDouble(bestReturn), GetDouble(bestParam1), GetDouble(bestParam2),
                        GetDouble(bestCalmar));
            }

        }

    }
}
