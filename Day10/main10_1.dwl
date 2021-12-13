%dw 2.0
import slice from dw::core::Arrays
import isNumeric from dw::core::Strings

output application/json

var lines = payload splitBy "\n"

type OPEN = "{" | "(" | "[" | "<"
type CLOSE =   "}" | ")" | "]" | ">"
type IN = OPEN | CLOSE

var score = {
    ")": 3,
    "]": 57,
    "}": 1197,
    ">": 25137
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

---
sum(lines flatMap ((line, index) -> 
    splitBy(line, "") reduce ((item, accumulator = []) -> 
        if(isNumeric(accumulator[-1]) default false)
             accumulator
        else
            stack(item, accumulator)
    )
) filter isNumeric($))