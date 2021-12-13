%dw 2.0
import slice from dw::core::Arrays
import isNumeric from dw::core::Strings

output application/json

var lines = payload splitBy "\n"

type OPEN = "{" | "(" | "[" | "<"
type CLOSE =   "}" | ")" | "]" | ">"

var score = {
    ")": 3,
    "]": 57,
    "}": 1197,
    ">": 25137
}

var scoreComplete = {
    ")": 1,
    "]": 2,
    "}": 3,
    ">": 4
}

fun getCloseSign(o: OPEN): CLOSE | Null =
    o match {
        case "{" -> "}" 
        case "(" -> ")"
        case "[" -> "]"
        case "<" -> ">"
        else -> null
    }

fun stack(in: String, arr: Array<String>): Array<Number | String> =
    in match {
        case is OPEN -> arr + in
        case is CLOSE -> 
            if(isEmpty(arr))
                [score[in]]
            else do {
                var expectedClose = getCloseSign(arr[-1])
                ---
                if(in == expectedClose)
                    slice(arr, 0, sizeOf(arr) - 1)
                else
                    [score[in]]
            }
    }

fun doComplete(in: Array<OPEN>, score: Number): Number =
    if(isEmpty(in))
        score
    else do {
        var openSign = in[-1]
        var closeSign = getCloseSign(openSign)
        ---
        closeSign match {
            case cs is CLOSE -> doComplete(slice(in, 0, sizeOf(in)-1), (score * 5) + scoreComplete[cs])
            case is Null  -> 0
    }

    }
        

var incompletes = (lines map ((line, index) -> 
    splitBy(line, "") reduce ((item, accumulator = []) -> 
        if(isNumeric(accumulator[-1]) default false)
            accumulator
        else
            stack(item, accumulator)
    )
)) filter ((item, index) -> not isNumeric(item[0]))

---
(incompletes map doComplete($, 0) orderBy $)[sizeOf(incompletes) / 2]