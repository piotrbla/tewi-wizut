using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace ForexTester.Strategies
{
    class S1A : BaseStrategy
    {
        public S1A(List<Candle> candles)
            : base(candles)
        {
        }

        public void ComputeStrategy(object selectedItem)
        {
            string filename = selectedItem + "." + ResultFileExtension;
            var bestReturn = -120.0;
            var candlesCount = Candles.Count;
            var bestCalmar = 0.0;
            var bestMa = 0;
            using (var writer = new StreamWriter(filename, false))
            {
                writer.WriteLine("results");
            }
            //paramALength: 9 paramAVolLength: 26 paramABuffer: -0.00416 paramAVolThreshold: 100 paramADuration: 16 paramASL: 0.00576 Calmar: 2.6312
            //const int paramALength=24;
            for (var paramALength = 10; paramALength <= 1000; paramALength += 1)//liczba swiec wstecz do obliczenia maksimum
            {
                var means = new List<double>(candlesCount) { Candles.First().Close };
                var kon = candlesCount - 1;
                for (var i = 1; i < kon; i++)
                    means.Add(GetCandlesRange(i, paramALength).Average(candle => candle.Close));
                //CreateStatus("paramALength: {0}", paramALength);
                //AppendStatus("  paramAVolLength: {0}\r\n", paramAVolLength);
                var sumRa = new List<double>(candlesCount);
                var returnValues = new List<double>(candlesCount);
                var drawdowns = new List<double>(candlesCount);
                var candlesBegin = paramALength + 1;
                var positionCount = 0; //liczba otwieranych pozycji
                //var stopLossCount = 0; //liczba stop lossów
                var lastCandle = kon;
                for (int i = 0; i < candlesBegin; i++)
                {
                    sumRa.Add(0);
                    returnValues.Add(0);
                }
                for (int i = candlesBegin; i < lastCandle; i++)
                {
                    returnValues.Add(0);
                    if (means[i] < Candles[i].Close)
                    {
                        returnValues[i] = Candles[i + 1].Close - Candles[i + 1].Open;
                        //zysk z i-tej pozycji long zamykanej na zamknięciu po 1 kroku
                        positionCount++;
                    }
                    sumRa.Add(sumRa[i - 1] + returnValues[i]);  //krzywa narastania kapitału
                }


                var recordReturn = 0.0;  //rekord zysku
                var recordDrawdown = 0.0;  //rekord obsuniecia
                for (int j = 0; j < lastCandle; j++)
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
                    bestMa = paramALength;
                    using (var writer = new StreamWriter(filename, true))
                    {
                        writer.WriteLine("{0}\t{1}\t{2}",
                                GetDouble(sumReturn), GetDouble(paramALength),
                                GetDouble(calmar));
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
