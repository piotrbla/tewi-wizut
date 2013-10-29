using System;
using System.Windows.Forms;
using System.IO;
using generator.Properties;

namespace generator
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void BtnGenerateClick(object sender, System.EventArgs e)
        {
            var outputFolder = "output" + DateTime.Now.ToString("yyyyMMdd_hhmmss");
            System.IO.Directory.CreateDirectory(outputFolder);
            System.IO.Directory.CreateDirectory(Path.Combine(outputFolder, "images"));
            var oneChartGeneratorMz = new ChartGenerator(outputFolder, "MZ");
            var s = new System.Text.StringBuilder(); 
            s.Append(oneChartGeneratorMz.Generate("cadchfS1{0}", "CADCHF"));
            s.Append(oneChartGeneratorMz.Generate("fcopperS1{0}", "FCOPPER"));
            s.Append(oneChartGeneratorMz.Generate("fcornS1{0}", "FCORN"));
            s.Append(oneChartGeneratorMz.Generate("nzdjpyS1{0}", "NZDJPY"));
            s.Append(oneChartGeneratorMz.Generate("usdcadS1{0}", "USDCAD"));
            File.WriteAllText(Path.Combine(outputFolder, "MZ.tex"), s.ToString());
            toolStripStatusLabel1.Text = Resources.btnGenerateClickGenerated;
        }
    }
}
