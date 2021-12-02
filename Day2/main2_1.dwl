%dw 2.0
output application/json

type Direction = "forward" | "down" | "up" 

type Movement = {
    direction: Direction,
    step: Number
}

var movements: Array<Movement> = payload splitBy "\n" map splitBy($, " ") map ({direction: $[0] as Direction, step: $[1] as Number})
var movementSums = movements groupBy $.direction mapObject {($$): sum($.*step)}

---

//1962940
movementSums.forward * (movementSums.down - movementSums.up)