using System.Collections.Generic;
using System.Windows.Forms.DataVisualization.Charting;

namespace ForexTester
{
    class ChartDrawing
    {
        private readonly Chart m_chart;

        public ChartDrawing(Chart chart)
        {
            m_chart = chart;
        }

        public void Draw(List<Candle> candles)
        {
            m_chart.Series.Clear();
            var candlesSeries = m_chart.Series.Add("candles");
            candlesSeries.ChartType = SeriesChartType.Candlestick;
            var upperLinesSeries = m_chart.Series.Add("upperLines");
            upperLinesSeries.ChartType = SeriesChartType.Line;
            var midLinesSeries = m_chart.Series.Add("midLines");
            midLinesSeries.ChartType = SeriesChartType.Line;
            var lowerLinesSeries = m_chart.Series.Add("lowerLines");
            lowerLinesSeries.ChartType = SeriesChartType.Line;
            var x = 0;
            var startSeries = m_chart.Series.Count;
            var channels = startSeries;
            const double delta = 0.001;
            foreach (var candle in candles)
            {
                candlesSeries.Points.Add(new DataPoint(x, new[] { candle.Low, candle.High, candle.Close, candle.Open }));
                if (x % 10 == 0)
                {
                    var channel = m_chart.Series.Add("channel" + channels);
                    channel.ChartType = SeriesChartType.Line;
                    channel.Points.Add(new DataPoint(x, candle.Close));
                    channels++;
                    if (channels > startSeries + 4)
                    {
                        var oldChannel = m_chart.Series[channels - 4];
                        oldChannel.Points.Add(new DataPoint(x, candle.Close));
                    }

                    //upperLinesSeries.Points.Add(new DataPoint(x, candle.Close + delta * candle.Close));
                    //midLinesSeries.Points.Add(new DataPoint(x, candle.Close));
                    //lowerLinesSeries.Points.Add(new DataPoint(x, candle.Close-delta*candle.Close));
                }
                x++;
                if (x > 50)
                    break;
            }

        }
    }
}
