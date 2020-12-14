import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.lang.Math;
import java.util.*;
import java.util.stream.*;

public class day13 {
    private static long waitTime(long start, int bus) {
      long times = (start + bus - 1) / bus;
      return (times * bus) - start;
    }

    private static boolean isPrime(int num) {
      int upto = (int)Math.sqrt(num);
      for (int div = 2; div <= upto; div++)
          if (num % div == 0) return false;
      return true;
    }

    private static long inv(long a, long m) {
      long m0 = m, t, q;
      long x0 = 0L, x1 = 1L;

      if (m == 1) return 0L;

      while (a > 1) {
        q = a / m;
        t = m;

        m = a % m;
        a = t;
        t = x0;

        x0 = x1 - q * x0;
        x1 = t;
      }

      if (x1 < 0) x1 += m0;

      return x1;
    }

    private static long minX(List<Long> num, List<Long> rem) {
      long prod = num.stream().reduce(1L, (a, b) -> a * b);
      long result = 0;
      for (int i=0; i<num.size(); i++) {
        long pp = prod / num.get(i);
        result += rem.get(i) * inv(pp, num.get(i)) * pp;
      }
      return result % prod;
    }
   public static void main(String []args) throws Exception {
      File file = new File("day13_input.txt");
      BufferedReader br = new BufferedReader(new FileReader(file));

      long start = Long.parseLong(br.readLine());
      long result = -1;
      long minWait = 9999999;

      List<Long> num = new ArrayList<Long>();
      List<Long> rem = new ArrayList<Long>();
      int inv = -1;
      for (String s: br.readLine().split(",")) {
          inv++;
          if (s.equals("x"))
              continue;

          int bus = Integer.parseInt(s);
          if (!isPrime(bus)) System.out.format("%d is not prime\n", bus);
          num.add((long)bus);
          rem.add((long)((bus-inv) % bus));

          long wait = waitTime(start, bus);
          if (wait < minWait) {
            result = bus * wait;
            minWait = wait;
          }
      }
      System.out.format("Part1: %d\n", result);
      System.out.format("Part2: %d\n", minX(num, rem));
   }
}
