%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Objects

output application/json

type Line = Array<Array<String>>

fun sortString(s: String): String = toString(s splitBy "" orderBy $)
fun toString(a: Array<String>): String = a reduce ((item, acc = "") -> acc ++ item)
fun toStringArray(a: String): Array<String> = a splitBy ""
fun hasElements(s: String, mandatoryElements): Boolean = 
    toStringArray(mandatoryElements) every(s contains $)

fun substract(a, b): String = 
    sortString(toString(toStringArray(a as String) -- toStringArray(b as String)))

fun decode(patterns: Object, signal: Array<String>) = do {
    var numbers = signal map (patterns[sortString($)])
    ---
    numbers reduce ((item, accumulator = "") -> "$(accumulator)$(item)")
}

var inputEntries: Array<Line> = splitBy(payload, "\n") map ($ splitBy("|") map($ splitBy " " filter(not isBlank($))))
---
inputEntries reduce ((line: Line, resultSum = 0) -> do {
    var knownPattern = line[0] ++ line[1] reduce ((pattern, patterns = {}) -> pattern match {
        case p if (sizeOf(p) == 2) -> patterns update {case i at ."1"! -> sortString(p) }
        case p if (sizeOf(p) == 4) -> patterns update {case i at ."4"! -> sortString(p) }
        case p if (sizeOf(p) == 3) -> patterns update {case i at ."7"! -> sortString(p) }
        case p if (sizeOf(p) == 7) -> patterns update {case i at ."8"! -> sortString(p) }
        else                                   -> patterns
    })
    // 2, 3, 5
    var fiveSegments = line[0] filter(sizeOf($) == 5) 
    var three = (fiveSegments filter ((item, index) -> ((sizeOf(substract(item, knownPattern["4"])) == 2) and (sizeOf(substract(item, knownPattern["1"])) == 3))))[0]
    var five = (fiveSegments filter ((item, index) -> ((sizeOf(substract(item, knownPattern["4"])) == 2) and (sizeOf(substract(item, knownPattern["1"])) == 4))))[0]
    var two  = (fiveSegments filter((sizeOf(substract($, knownPattern["4"]))) == 3))[0]

    var knownPattern2 = {
        "2": sortString(two),
        "3": sortString(three),
        "5": sortString(five)
    }
    
    ////0, 6, 9    
    var sixSegments = line[0] filter(sizeOf($) == 6)
    var nine:String = (sixSegments filter((sizeOf(substract($, knownPattern["4"])) == 2)))[0]
    var six: String = (sixSegments filter((sizeOf(substract($, knownPattern["1"])) == 5)))[0]
    var zero: String = (sixSegments filter((sizeOf(substract($, knownPattern["1"])) == 4 and (not hasElements($, nine)))))[0] 

    var knownPattern3 = {
        "0": sortString(zero),
        "6": sortString(six),
        "9": sortString(nine) 
    }

    var allPattern = knownPattern ++ knownPattern2 ++ knownPattern3
    var swappedMap = allPattern mapObject ((value, key, index) -> (value): key)

    ---
    resultSum + decode(swappedMap, line[1]) as Number
})


