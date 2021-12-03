%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Numbers

output application/json

fun transpose(in: Array<String>, acc: Array<String>): Array<String> = (
    if(isBlank(in[0]))
        acc
    else
        transpose(in map $[1 to -1], acc ++ [in reduce ((row, newRow = "") ->  newRow ++ row[0]) ])
)

fun transpose(in: Array<String>): Array<String> = transpose(in, [])

fun countChar(in: String, char: String): Number = in splitBy  "" countBy $ == char

fun oxygenGeneratorCommonBit(in: String): String = do {
        var zeros = countChar(in, "0")
        var ones  = countChar(in, "1")
        ---
        if(zeros > ones)
            "0"
        else if (zeros < ones)
            "1"
        else 
            "1"
    }

fun co2ScrubberCommonBit(in: String): String = do {
        var zeros = countChar(in, "0")
        var ones  = countChar(in, "1")
        ---
        if(zeros < ones)
            "0"
        else if (zeros > ones)
            "1"
        else 
            "0"
    }

fun findRating(originalBits: Array<String>, index: Number, commonBit: (String) -> String): Array<String> = (
    if(sizeOf(originalBits) <= 1)
        originalBits
    else do {
        var bitsTransposed: Array<String>  = transpose(originalBits)
        var bit: String                    = commonBit(bitsTransposed[index])
        var significantBits: Array<String> = originalBits filter ($[index] == bit)
        ---
        findRating(significantBits, index + 1, commonBit)
    }   
)

fun findRating(originalBits: Array<String>, commonBit: (String) -> String): String = findRating(originalBits, 0, commonBit)[0]

var bits            = payload splitBy "\n"
var decimalOxygen   = fromBinary(findRating(bits, oxygenGeneratorCommonBit))
var decimalScrubber = fromBinary(findRating(bits, co2ScrubberCommonBit))

---
//3765399
decimalOxygen * decimalScrubber