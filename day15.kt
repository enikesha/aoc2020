//  kotlinc day15.kt -include-runtime -d day15.jar && java -jar day15.jar
fun main() {
    val input = arrayOf(15,5,1,4,7,0)
    //val nth = 2020
    val nth = 30000000

    val history = IntArray(nth+1) { -1 }
    input.dropLast(1).mapIndexed{i,v-> history[v] = i+1}
    var last = input.last()
    for (i in input.size+1 .. nth) {
        var next = history[last]
        next = if (next == -1) 0 else i-1-next
        history[last] = i-1
        last = next
    }
    println("$nth: ${last}")
}
