using System.Collections.Generic;
using System.IO;

namespace ForexTester.Strategies
{
    class EarthWorm : BaseStrategy
    {
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
        public void ComputeStrategy(object selectedItem)
        {
            var filename = selectedItem + "." + ResultFileExtension;
            var bestReturn = -120.0;
            var candlesCount = Candles.Count;
            var bestCalmar = 0.0;
            var bestMa = 0;
            var shortPositionOpen = 0;
            var longPositionOpen = 0;
            const double defaultSpread = 0.0002;
            using (var writer = new StreamWriter(filename, false))
            {
                writer.WriteLine("results");
            }
            for (var param1 = 20; param1 <= 20; param1 += 1)
            {
                for (var param2 = 1; param2 <= 1; param2++)
                {
                    var transactionState = TransactionStates.None;
                    var candlesBegin = param1 + 1;
                    var kon = candlesCount - 1;
                    var lastCandle = kon;
                    var sumRa = new List<double>(candlesCount);
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
                        for (var j = i-param1; j < i-1; j++)
                        {
                            if(Candles[j].Close>Candles[j+1].Close)
                                downCandlesCount++;
                        }
                        double spread;
                        if (downCandlesCount > param1 / 2 + param2)
                        {
                            spread = transactionState == TransactionStates.Short ? 0 : defaultSpread;
                            shortPositionOpen++;
                            positionReturn = Candles[i].Close - Candles[i + 1].Close - spread;
                            transactionState = TransactionStates.Short;
                        }
                        if (downCandlesCount < param1 / 2 - param2)
                        {
                            spread = transactionState == TransactionStates.Long ? 0 : defaultSpread;
                            longPositionOpen++;
                            positionReturn = -Candles[i].Close + Candles[i + 1].Close - spread;
                            transactionState = TransactionStates.Long;
                        }
                        returnValues.Add(positionReturn);
                        sumRa.Add(sumRa[i - 1] + returnValues[i]);  //krzywa narastania kapitału
                    }


                    var recordReturn = 0.0;  //rekord zysku
                    var recordDrawdown = 0.0;  //rekord obsuniecia
                    for (var j = 0; j < lastCandle; j++)
                    {
                        if (sumRa[j] > recordReturn)
                        {
                            recordReturn = sumRa[j];
                        }
                        drawdowns.Add(sumRa[j] - recordReturn);//róznica pomiedzy bieżącą wartoscia kapitału skumulowanego a dotychczasowym rekordem
                        if (drawdowns[j] < recordDrawdown)
                            recordDrawdown = drawdowns[j];  //obsuniecie maksymalne
                    }

                    //wyniki końcowe
                    var sumReturn = sumRa[lastCandle - 1];
                    var calmar = -sumReturn / recordDrawdown;  //wskaznik Calmara
                    if (bestReturn < sumReturn)
                    {
                        bestReturn = sumReturn; bestCalmar = calmar;
                        bestMa = param1;
                        using (var writer = new StreamWriter(filename, true))
                        {
                            writer.WriteLine("{0}\t{1}\t{2}",
                                    GetDouble(sumReturn), GetDouble(param1),
                                    GetDouble(calmar));
                        }
                    }
                }
            }
            using (var writer = new StreamWriter(filename, true))
            {
                writer.WriteLine("{0}\t{1}\t{2}",
                        GetDouble(bestReturn), GetDouble(bestMa),
                        GetDouble(bestCalmar));
            }

        }

    }
}
