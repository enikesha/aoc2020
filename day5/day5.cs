using System;
using System.Collections.Generic;
using System.Linq;

namespace day5
{
    class Program
    {
        static void Main(string[] args)
        {
            IEnumerable<string> ReadLines()
            {
              string line;
              while ((line = Console.ReadLine()) != null) {
                yield return line;
              }
            }
            var s = ReadLines().Select(l=>l.Select((c,i)=>(i:9-i,b:(c=='B'||c=='R')?1:0)).Aggregate(0, (a,x)=>a+(x.b<<x.i))).ToArray();
            Console.WriteLine(s.Max());
            Console.WriteLine((s.Count()+1)*(2*s.Min()+s.Count())/2-s.Sum());
        }
    }
}
