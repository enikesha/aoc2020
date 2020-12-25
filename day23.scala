// scalac day23.scala && scala day23

object day23 extends App {
  def parse(cups: String) = cups.map(_.toInt - 0x30).toList
  def setup(input: List[Int], n: Int) = {
    val index = Array.range(1, n+2)
    index(n) = input(0)
    input.zipWithIndex.foreach {case (v,i) =>
      index(v) = if (i < input.length-1)
        input(i+1)
      else if ((i+2) > n)
        input(0)
      else i+2
    }
    index
  }
  def round(cur: Int, index: Array[Int]) = {
    val pick = index(cur)
    var next = cur
    do { next = if ((next - 1) < 1) index.length-1 else next - 1 }
    while ((next == pick) || (next == index(pick)) || (next == index(index(pick))))
    index(cur) = index(index(index(pick)))
    index(index(index(pick))) = index(next)
    index(next) = pick
    index(cur)
  }

  def game(index: Array[Int], rounds: Int, start: Int) = {
    var cur = start
    for (i <- 1 to rounds) { cur = round(cur, index) }
    index
  }

  def printResult(index: Array[Int]) = {
    var cur = 1
    for (i <- 1 to index.length-2) {
      print(index(cur))
      cur = index(cur)
    }
    println()
  }
  def printMul(index: Array[Int]) = println(1L * index(1) * index(index(1)))

  //val input = parse("389125467")
  val input = parse("598162734")
  printResult(game(setup(input, input.length), 100, input(0)))
  printMul(game(setup(input, 1_000_000), 10_000_000, input(0)))
}
