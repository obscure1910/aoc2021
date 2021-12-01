%dw 2.0
output application/json
import * from dw::core::Arrays

var data = payload splitBy "\n" map $ as Number
var sums = data map sum(slice(data, 0 + $$, 3 + $$))
var zipWithPrev = ([0] ++ sums) zip sums

---
//1683
sizeOf (zipWithPrev filter $[0] < $[1]) - 1 