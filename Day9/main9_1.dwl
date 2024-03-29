%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Objects

output application/json

type Point = {
    x: Number,
    y: Number
}

type ValuePoint = {
    point: Point,
    element: Number
}

var matrix = splitBy(payload, "\n") map($ splitBy "" map $ as Number)
var upperBoundX = sizeOf(matrix[0]) - 1
var upperBoundY = sizeOf(matrix) - 1
var riskLevel = 1

fun emptyIfOutOfBounds(p: Point): Array<ValuePoint> =
    if (p.x < 0 or p.y < 0 or p.x > upperBoundX or p.y > upperBoundY)
        []
    else
        [{
            point: p,
            element: matrix[p.y][p.x]
        }]

fun valuesOfAdjacents(p: Point): Array<ValuePoint> = 
    flatten([
        emptyIfOutOfBounds({x: p.x, y: p.y + 1 }), //top
        emptyIfOutOfBounds({x: p.x + 1, y: p.y}),  //right
        emptyIfOutOfBounds({x: p.x, y: p.y - 1 }), //down
        emptyIfOutOfBounds({x: p.x - 1, y: p.y})   //left
    ])
  
var lowPoints = (matrix flatMap ((row, yy) -> 
    row flatMap ((column, xx) -> do {
        var point: Point = {x: xx, y: yy}
        var element: Number = matrix[yy][xx]
        var valuePoint: ValuePoint = {point: point, element: element} as ValuePoint
        var values = (valuesOfAdjacents(point) - null) map $.element
        var minimum = min([element] ++ values)
        ---
        if(minimum == element and !contains(values, element)) 
            [valuePoint] 
        else []
    })
))

---
sum((lowPoints map $.element + 1))