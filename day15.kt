//  kotlinc day15.kt -include-runtime -d day15.jar && java -jar day15.jar
fun main() {
    val input = arrayOf(15,5,1,4,7,0)
    val nth = 30000000
    val other = 2020


    val history = input.dropLast(1).mapIndexed{i,v->v to i+1}.associate{i->i}.toMutableMap()
    var last = input.last() to input.size
    for (i in input.size+1 .. nth) {
        val next = history.get(last.first).let { if (it != null) last.second-it else 0 }
        if (i == other) println("$i: $next")
        history[last.first] = last.second
        last = next to i
    }
    println("$nth: ${last.first}")
}
