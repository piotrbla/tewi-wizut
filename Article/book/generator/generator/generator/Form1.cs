using System;
using System.Text;
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
            var builderMz = new System.Text.StringBuilder();
            builderMz.Append(oneChartGeneratorMz.Generate("cadchfS1{0}", "CADCHF"));
            builderMz.Append(oneChartGeneratorMz.Generate("fcopperS1{0}", "FCOPPER"));
            builderMz.Append(oneChartGeneratorMz.Generate("fcornS1{0}", "FCORN"));
            builderMz.Append(oneChartGeneratorMz.Generate("nzdjpyS1{0}", "NZDJPY"));
            builderMz.Append(oneChartGeneratorMz.Generate("usdcadS1{0}", "USDCAD"));
            File.WriteAllText(Path.Combine(outputFolder, "MZ.tex"), builderMz.ToString());
            var oneChartGeneratorAb = new ChartGenerator(outputFolder, "AB");
            var builderAb = new System.Text.StringBuilder();
            builderAb.Append(oneChartGeneratorAb.Generate("chfjpy{0}", "CHFJPY"));
            builderAb.Append(oneChartGeneratorAb.Generate("eurjpy{0}", "EURJPY"));
            builderAb.Append(oneChartGeneratorAb.Generate("fus500{0}", "FUS500"));
            builderAb.Append(oneChartGeneratorAb.Generate("gbpchf{0}", "GBPCHF"));
            builderAb.Append(oneChartGeneratorAb.Generate("silver{0}", "SILVER"));
            File.WriteAllText(Path.Combine(outputFolder, "AB.tex"), builderAb.ToString());
            WriteMainFile(outputFolder, "MZ;AB");
            toolStripStatusLabel1.Text = Resources.btnGenerateClickGenerated;
        }

        private static void WriteMainFile(string outputFolder, string initials )
        {
            StringBuilder allContent = new StringBuilder();
            foreach (var initial in initials.Split(new char[] {';'}))
            {
                allContent.Append(File.ReadAllText(Path.Combine(outputFolder, initial + ".tex")));
            }
            File.WriteAllText(Path.Combine(outputFolder, "MAIN.tex"), allContent.ToString());
        }
    }
}
