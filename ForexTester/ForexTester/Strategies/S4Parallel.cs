using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace ForexTester.Strategies
{
    class S4Parallel : BaseStrategy
    {
        public S4Parallel(List<Candle> candles)
            : base(candles)
        {
        }

        public void ComputeStrategy2(object selectedItem)
        {
            var candlesCount = Candles.Count;
            double[] maxes100 = new double[101];
            Parallel.For(1, 100, paramALength =>
                {
                    var maxes = new List<double>(candlesCount) { Candles.First().Close };
                    var kon = candlesCount - 1;
                    var localparamALength = paramALength;
                    for (var i = 1; i < kon; i++)
                        maxes.Add(GetCandlesRange(i, localparamALength).Min(candle => candle.Close));//TODO: Change to High
                    maxes100[localparamALength] = maxes[1000];

                });
            maxes100[0] = 1;

        }

        public void ComputeStrategy(object selectedItem)
        {
            var filename = selectedItem + "." + ResultFileExtension;
            var bestReturn = -120.0;
            var candlesCount = Candles.Count;
            //var bestCalmar = 0.0;
            //var bestMa = 0;
            //var bestparamAVolLength = 0;
            //var bestparamADuration = 0;
            //var bestparamABuffer = 0.0;
            //var bestparamAVolThreshold = 0.0;
            //var bestparamAsl = 0.0;
            const double spread = 0.00016;
            using (var writer = new StreamWriter(filename, false))
            {
                writer.WriteLine("results");
            }
            //paramALength: 9 paramAVolLength: 26 paramABuffer: -0.00416 paramAVolThreshold: 100 paramADuration: 16 paramASL: 0.00576 Calmar: 2.6312
            //const int paramALength=9;
            Parallel.For(9, 19, paramALength =>
            {
            //for (var paramALength = 9; paramALength <= 19; paramALength += 10)//liczba swiec wstecz do obliczenia maksimum
            //{
                var localparamALength = paramALength;
                var maxes = new List<double>(candlesCount) { Candles.First().Close };
                var kon = candlesCount - 1;
                for (var i = 1; i < kon; i++)
                    maxes.Add(GetCandlesRange(i, localparamALength).Max(candle => candle.Close));//TODO: Change to High
                const int paramAVolLength = 26;
                //for (int paramAVolLength = 26; paramAVolLength <= 26/*38*/; paramAVolLength++)
                {
                    //CreateStatus("localparamALength: {0}", localparamALength);
                    //AppendStatus("  paramAVolLength: {0}\r\n", paramAVolLength);
                    var volAverages = new List<double>(candlesCount) { 0 };
                    for (var i = 1; i < kon; i++)
                        volAverages.Add(GetCandlesRange(i, localparamALength).Average(candle => candle.Volume) - Candles[i].Volume);
                    //const int paramADuration = 16;
                    for (var paramADuration = 6; paramADuration <= 16; paramADuration++)//liczba kroków wprzód do zamkniecia pozycji
                    {
                        //for (var paramAVolThreshold = -100; paramAVolThreshold <= 100; paramAVolThreshold += 100)//próg dla sredniego wolumenu
                        const int paramAVolThreshold = 100;
                        {
                            for (var paramABuffer = -spread * 28; paramABuffer <= spread; paramABuffer += spread)
                            //dla kwadrantu a i b szukamy ujemnych wartości, dla kwadrantów c i d dodatnich wartości bufora
                            //const double paramABuffer = -0.00416;
                            {
                                //const double paramAsl = 0.00576;
                                for (var paramAsl = spread * 35; paramAsl <= spread * 48; paramAsl += spread)//Stop Loss minimalnie może być równy 8*spread 0.00384%
                                {
                                    var sumRa = new List<double>(candlesCount);
                                    var returnValues = new List<double>(candlesCount);
                                    var drawdowns = new List<double>(candlesCount);
                                    var candlesBegin = Math.Max(paramAVolLength, localparamALength) + 1;
                                    //var positionCount = 0; //liczba otwieranych pozycji
                                    //var stopLossCount = 0; //liczba stop lossów
                                    var lastCandle = kon - Math.Max(localparamALength, paramAVolLength) - paramADuration;
                                    for (int i = 0; i < candlesBegin; i++)
                                    {
                                        sumRa.Add(0);
                                        returnValues.Add(0);
                                    }
                                    for (int i = candlesBegin; i < lastCandle; i++)
                                    {
                                        returnValues.Add(0);
                                        if (maxes[i] + paramABuffer < Candles[i].Close && volAverages[i] < paramAVolThreshold)
                                        {
                                            returnValues[i] = Candles[i + paramADuration].Close - Candles[i + 1].Open - spread;
                                            //zysk z i-tej pozycji long zamykanej na zamknięciu po paramADuration kroku
                                            var minLow = Candles.GetRange(i + 1, paramADuration - 1).Min(candle => candle.Low);
                                            if ((-Candles[i + 1].Open + minLow) < -paramAsl)
                                            {
                                                returnValues[i] = -paramAsl;
                                                //stopLossCount++;
                                            }
                                            //positionCount++;
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
                                    //var calmar = -sumReturn / recordDrawdown;  //wskaznik Calmara
                                    if (bestReturn < sumReturn)
                                    {
                                        bestReturn = sumReturn; //bestCalmar = calmar;
                                        //bestMa = localparamALength;
                                        //bestparamAVolLength = paramAVolLength;
                                        //bestparamADuration = paramADuration;
                                        //bestparamABuffer = paramABuffer;
                                        //bestparamAVolThreshold = paramAVolThreshold;
                                        //bestparamAsl = paramAsl;
                                        //using (var writer = new StreamWriter(filename, true))
                                        //{
                                        //    writer.WriteLine("{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}",
                                        //            getDouble(sumReturn), getDouble(localparamALength),
                                        //            getDouble(paramAVolLength), getDouble(paramADuration), getDouble(paramAVolThreshold),
                                        //            getDouble(paramABuffer), getDouble(paramAsl), getDouble(calmar));
                                        //}
                                        //CreateStatus("  \r\nzysk: {0}", sumReturn);
                                        //AppendStatus("  localparamALength: {0}", localparamALength);
                                        //AppendStatus("  paramAVolLength: {0}", paramAVolLength);
                                        //AppendStatus("  paramADuration: {0}", paramADuration);
                                        //AppendStatus("  paramAVolThreshold: {0}", paramAVolThreshold);
                                        //AppendStatus("  paramABuffer: {0}", paramABuffer);
                                        //AppendStatus("  paramASL: {0}", paramAsl);
                                        //AppendStatus("  Calmar: {0}", calmar);
                                        //Application.DoEvents();
                                    }
                                }
                            }
                        }
                    }
                }
            //}
            });

            //CreateStatus("zysk: {0}", 0);
            //AppendStatus("  paramALength: {0}", bestMa);
            //AppendStatus("  paramAVolLength: {0}", bestparamAVolLength);
            //AppendStatus("  paramABuffer: {0}", bestparamABuffer);
            //AppendStatus("  paramAVolThreshold: {0}", bestparamAVolThreshold);
            //AppendStatus("  paramADuration: {0}", bestparamADuration);
            //AppendStatus("  paramASL: {0}", bestparamAsl);
            //AppendStatus("  Calmar: {0}", bestCalmar);
        }
    }
}
