using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ParamGenerator
{
    class Program
    {
        static void Main(string[] args)
        {
            string filename = "../../tewiMiCAB.csv";
            using (StreamReader csv = new StreamReader(new FileStream(filename, FileMode.Open)))
            {
                string csvline;
                string[] names = null;

                List<string[]> lines = new List<string[]>();

                while ((csvline = csv.ReadLine()) != null)
                {
                    // 1000;0;2012-02-18;0.0057;-0.0009;20;3;34;0.005;0.0059;7;153;7;15;0.0011;0.0019
                    string[] csvargs = csvline.Split(new char[] { ';' });

                    if (names == null)
                    {
                        names = csvargs;
                        continue;
                    }

                    lines.Add(csvargs);
                }

                lines.Reverse();

                using (StreamWriter sw = new StreamWriter(new FileStream("output.txt", FileMode.OpenOrCreate)))
                {
                    foreach (string[] csvargs in lines)
                    {
                        sw.WriteLine(string.Format("else if (candle >= {0} && candle < {0}+100)", csvargs[0]));
                        sw.WriteLine("{");
                        for (int idx = 0; idx < names.Length; idx++)
                        {
                            if (names[idx].Length == 0 || names[idx][0] == '_')
                            {
                                continue;
                            }

                            sw.WriteLine(string.Format("{0} = {1};", names[idx], csvargs[idx]));
                        }
                        sw.WriteLine("process_arguments();");
                        sw.WriteLine("}");
                    }

                    sw.WriteLine("else");
                    sw.WriteLine("{");
                    sw.WriteLine("return(0);");
                    sw.WriteLine("}");
                }
            }
        }
    }
}
