%dw 2.0
output application/json

var data = payload splitBy "\n" map $ as Number
var sums = data flatMap ((item, index) -> [0 + index to 2 + index] map data[$]) filter $ != null map sum($)
var zipWithPrev = ([0] ++ sums) zip sums

---
//1683
sizeOf (zipWithPrev filter $[0] < $[1]) - 1 