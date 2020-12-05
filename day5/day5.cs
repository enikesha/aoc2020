using System;
using System.Collections.Generic;
using System.Linq;

namespace day5
{
    class Program
    {
        static void Main(string[] args)
        {
            IEnumerable<string> ReadLines() {string l; while ((l=Console.ReadLine())!=null){yield return l;}};
            Console.WriteLine(new[]{ReadLines().Select(l=>l.Select(c=>(c=='B'||c=='R')?1:0).Aggregate(0,(a,x)=>a*2+x))
                                               .Aggregate((min:1024,max:0,sum:0),(a,i)=>(Math.Min(i,a.min),Math.Max(i,a.max),a.sum+i))}
                              .Select(s=>(s.max, (s.max-s.min+1)*(s.max+s.min)/2-s.sum)).First());
        }
    }
}
