%dw 2.0
output application/json

var data = payload splitBy "\n" map $ as Number
var zipWithPrev = ([0] ++ data) zip data

---

//1655
sizeOf (zipWithPrev filter $[0] < $[1]) - 1 