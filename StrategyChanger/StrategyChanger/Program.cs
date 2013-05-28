using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;

namespace ConsoleApplication1
{
    class Program
    {
        private static Dictionary<string, string> m_varnames;
        private static Dictionary<char, Dictionary<int, string>> m_changes;

        static void Main(string[] args)
        {
            if (args.Length < 1)
            {
                Console.WriteLine("No filename given.");
                return;
            }
            var filename = args[0];
            if (!File.Exists(filename))
            {
                Console.WriteLine("No file " + filename + " found.");
                return;
            }
            var data = File.ReadAllLines(filename, Encoding.Default);
            var baseFilename = Path.GetFileNameWithoutExtension(filename);
            var baseExtension = Path.GetExtension(filename);
            ReadVarNames("varnames.txt");
            ReadChanges();
            foreach (var c in "abcd")
            {
                if (baseFilename != null)
                    using (var writer = new StreamWriter(baseFilename + c + baseExtension, false, Encoding.Default))
                    {
                        var lineNo = 1;
                        var letterChanges = m_changes[Convert.ToChar(c.ToString(CultureInfo.InvariantCulture).ToUpper())];
                        foreach (var line in data)
                        {
                            var modifiedLine = line;
                            if (letterChanges.ContainsKey(lineNo))
                                modifiedLine = letterChanges[lineNo];
                            foreach (var varname in m_varnames)
                            {
                                if (modifiedLine.Contains(varname.Key))
                                    modifiedLine = modifiedLine.Replace(varname.Key, 
                                        varname.Value.Replace("{A}", c.ToString(CultureInfo.InvariantCulture).ToUpper()));
                            }
                            writer.WriteLine(modifiedLine);
                            lineNo++;
                        }
                    }
            }


        }

        private static void ReadChanges()
        {
            m_changes = new Dictionary<char, Dictionary<int, string>>();
            foreach (var c in "ABCD")
            {
                var data = File.ReadAllLines("changes" + c + ".txt", Encoding.Default);
                var letterChanges = data.Select(
                    line => line.Split(new[] {':'}, 2)).ToDictionary(
                        elements => Convert.ToInt32(elements[0]), 
                        elements => elements[1]);
                m_changes.Add(c, letterChanges);
            }
        }

        private static void ReadVarNames(string varnamesFilename)
        {
            var data = File.ReadAllLines(varnamesFilename, Encoding.Default);
            m_varnames = new Dictionary<string, string>();
            foreach (var line in data)
            {
                m_varnames.Add(line.Replace("{", "").Replace("}", ""), line);
            }
        }
    }
}
