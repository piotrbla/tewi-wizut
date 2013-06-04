using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Windows.Forms;
using ForexTester.Strategies;

namespace ForexTester
{
    public partial class Tester : Form
    {
        const string m_ValuesFileExtension = "csv";
        const string m_MatlabFileExtension = "m";
        public Tester()
        {
            InitializeComponent();
        }

        private void Form1Load(object sender, EventArgs e)
        {
            LoadFilesToCombo();
        }

        private void LoadFilesToCombo()
        {
            foreach (var fullFilename in Directory.GetFiles(".", "*." + m_ValuesFileExtension, SearchOption.TopDirectoryOnly))
            {
                var fileName = Path.GetFileNameWithoutExtension(fullFilename);
                if (fileName != null) cmbFiles.Items.Add(fileName);
            }
            if (cmbFiles.Items.Count>0)
                cmbFiles.SelectedItem = cmbFiles.Items[0];
        }

        private void Button1Click(object sender, EventArgs e)
        {
            LoadData();
            ComputeLines();
            var chartDrawing = new ChartDrawing(chart1);
            chartDrawing.Draw(m_candles);
        }

        private void LoadData()
        {
            //var data = File.ReadAllLines("EURUSD1." + m_ValuesFileExtension );
            //var data = File.ReadAllLines("EURUSD60." + m_ValuesFileExtension);
            var data = File.ReadAllLines(cmbFiles.SelectedItem + "." + m_ValuesFileExtension);

            m_candles = new List<Candle>(data.Select(s => s.Split(',')).Select(values => new Candle
                {
                    Date = values[0],
                    Time = values[1],
                    Open = Convert.ToDouble(values[2].Replace(".", ",")),
                    High = Convert.ToDouble(values[3].Replace(".", ",")),
                    Low = Convert.ToDouble(values[4].Replace(".", ",")),
                    Close = Convert.ToDouble(values[5].Replace(".", ",")),
                    Volume = Convert.ToDouble(values[6].Replace(".", ","))
                }).ToList());
            ComputeAverages();
            if (chkMatlab.Checked)
                GenerateToMatlab();
        }

        private void GenerateToMatlab()
        {
            using (var writer = new StreamWriter(cmbFiles.SelectedItem + "." + m_MatlabFileExtension, false))
            {
                writer.WriteLine("C=[");
                foreach (var candle in m_candles)
                {
                    writer.WriteLine("{0}\t{1}\t{2}\t{3}\t{4}",
                        getDouble(candle.Open), getDouble(candle.High),
                        getDouble(candle.Low), getDouble(candle.Close), getDouble(candle.Volume));
                }
                writer.WriteLine("];");
            }
        }

        private string getDouble(double value)
        {
            return value.ToString("0.00000", CultureInfo.InvariantCulture);
        }

        private void AppendStatus(string format, long arg0)
        {
            lblStatus.Text += String.Format(format, arg0);
            txtStatus.Text += String.Format(format, arg0);
        }

        private void AppendStatus(string format, double arg0)
        {
            lblStatus.Text += String.Format(format, arg0);
            txtStatus.Text += String.Format(format, arg0);
        }

        private void CreateStatus(string format, object arg0)
        {
            lblStatus.Text = String.Format(format, arg0);
            txtStatus.Text += "\n" + String.Format(format, arg0);
        }

        private void ComputeAverages()
        {
            var watch = new Stopwatch();
            watch.Start();
            //var s = new S4(m_candles);
            //var s = new S4Parallel(m_candles);
            //var s = new S1A(m_candles.GetRange(0, 5000));
            S1Parallel s  =
               new S1AParallel(m_candles.GetRange(0, 5000));
            s.ComputeStrategy(cmbFiles.SelectedItem);
            s = new S1BParallel(m_candles.GetRange(0, 5000));
            s.ComputeStrategy(cmbFiles.SelectedItem);
            s = new S1CParallel(m_candles.GetRange(0, 5000));
            s.ComputeStrategy(cmbFiles.SelectedItem);
            s = new S1DParallel(m_candles.GetRange(0, 5000));
            s.ComputeStrategy(cmbFiles.SelectedItem);


            watch.Stop();
            CreateStatus("\r\nElapsed: {0}", watch.Elapsed);
            AppendStatus("  In milliseconds: {0}", watch.ElapsedMilliseconds);
            AppendStatus("  In timer ticks: {0}", watch.ElapsedTicks);
        }


        List<Candle> m_candles;
        Dictionary<int, ThreePointLine> m_lines;

        private void ComputeLines()
        {
            m_lines = new Dictionary<int, ThreePointLine>();
            var x = 0;
            var trends = 0;
            foreach (var candle in m_candles)
            {
                if (x % 10 == 0)
                {
                    m_lines.Add(x, new ThreePointLine { X0 = x, Y0 = candle.Close });
                    trends++;
                    if (trends > 4)
                    {
                        var line = m_lines[x - 40];
                        line.X1 = x;
                        line.Y1 = candle.Close;
                        line.X2 = line.X1 + line.X1 - line.X0;
                        line.Y2 = line.Y1 + line.Y1 - line.Y0;
                    }
                }
                x++;
            }
        }

    }
}
