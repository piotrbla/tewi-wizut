using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;

namespace generator
{
    class ChartGenerator
    {
        private readonly string outputFolder;
        private readonly string authorInitials;
        public ChartGenerator(string outputFolder, string authorInitials)
        {
            this.outputFolder = outputFolder;
            this.authorInitials = authorInitials;
        }

        public string Generate(string filenameFormat, string marketName)
        {
            var imagesFolder = Path.Combine(outputFolder, "images");
            var variantNamePlace = filenameFormat.IndexOf("{0}", System.StringComparison.InvariantCulture)+1;
            Debug.Assert(variantNamePlace > 0, "variantNamePlace>0");
            var labels = new List<string>(){"jedno", "dwu", "cztero", "mansard", "mansard"};
            var texFilePath = Path.Combine(outputFolder, authorInitials + marketName + ".tex");
            using (TextWriter writer = new StreamWriter(texFilePath))
            {
                writer.WriteLine(@"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
                writer.WriteLine(@"\newpage");
                writer.WriteLine(@"\begin{table}[!t]");
                writer.WriteLine(@"\caption{Profits for all strategy quadrants for " + marketName + "}");
                writer.WriteLine(@" \begin{center}");
                writer.WriteLine(@" \begin{tabular}{|l|l|l|l|l|}");
                writer.WriteLine(@" \hline \textbf{strategy} & \textbf{profit} & \textbf{bestCalmar} & \textbf{bestMALength} & \textbf{la} \\ \hline");
                writer.WriteLine(@"S1a & 17.19 & 8.24 & 18 & 2693\\ \hline");
                writer.WriteLine(@"S1b & -9.80 & -0.74 & 54 & 2665\\ \hline");
                writer.WriteLine(@"S1c & 5.65 & 2.06 & 54 & 2280\\ \hline");
                writer.WriteLine(@"S1d & 1.87 & 0.61 & 18 & 2287\\ \hline");
                writer.WriteLine(@"S1s & 14.85 & 5.68 & Group of MA & 4945\\"); 
                writer.WriteLine(@"\hline \end{tabular}");
                writer.WriteLine(@" \end{center}");
                writer.WriteLine(@" \end{table}");
                writer.WriteLine(@"\FloatBarrier");
                writer.WriteLine(@"\begin{figure}[h]");
                writer.WriteLine(@"\centering");
                var loopIndex = 0;
                foreach (var pictureFile in Directory.GetFiles(authorInitials, string.Format(filenameFormat + ".png", "*")))
                {
                    writer.WriteLine(loopIndex == 4
                                         ? @"\begin{minipage}{.49\linewidth}"
                                         : @"\begin{minipage}{\linewidth}");
                    writer.WriteLine(@"\centering");
                    var widthValue = (loopIndex == 4) ? "0.82" : "0.6";
                    writer.WriteLine(@"\includegraphics[width=" + widthValue + @"\textwidth]{images/" + Path.GetFileName(pictureFile) + "}");
                    writer.WriteLine(@"\subcaption{Profit - " + pictureFile.Substring(variantNamePlace, 3) + "}");
                    writer.WriteLine(@"\label{" + labels[loopIndex]  + "}");
                    writer.WriteLine(@"\end{minipage}");
                    if (loopIndex == 1)
                        writer.WriteLine(@"\\");
                    loopIndex++;
                    File.Copy(pictureFile, Path.Combine(imagesFolder, Path.GetFileName(pictureFile)));
                }
                writer.WriteLine(@"\caption{" + marketName  + " market results}");
                writer.WriteLine(@"\end{figure}");
            }
            return File.ReadAllText(texFilePath);
        }
    }
}
