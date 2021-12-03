%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Numbers

output application/json

fun transpose(in: Array<String>, acc: Array<String>): Array<String> = (
    if(isBlank(in[0]))
        acc
    else
        do {
            var transposedRow = in reduce ((row, newRow = "") ->  newRow ++ row[0]) 
            ---
            transpose(in map $[1 to -1], acc ++ [in reduce ((row, newRow = "") ->  newRow ++ row[0]) ])
        }
)

fun countChar(in: String, char: String): Number = in splitBy  "" countBy $ == char

fun mostCommonBit(in: String): String = if (countChar(in, "0") > countChar(in, "1")) "0" else "1"

fun transpose(in: Array<String>): Array<String> = transpose(in, [])

fun invertBinary(in: String): String = in splitBy "" reduce ((item, accumulator = "") -> accumulator ++ if (item == "1") "0" else "1")

var bits           = payload splitBy "\n"
var transposedBits = transpose(bits, [])
var mostCommonBits = transpose(transposedBits map mostCommonBit($))[0]
var gammaBinary    = mostCommonBit
var gammaDecimal   = fromBinary(mostCommonBits)
var epsilonBinary  = invertBinary(mostCommonBits)
var epsilonDecimal = fromBinary(epsilonBinary)

---
epsilonDecimal * gammaDecimal