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
var highestValue = 9

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
        var values = valuesOfAdjacents(point) map $.element
        var minimum = min(values + element)
        ---
        if(minimum == element and !contains(values, element)) 
            [valuePoint] 
        else []
    })
))

fun basin(value: ValuePoint, visited: Array<ValuePoint>): Array<ValuePoint> = 
    if((visited contains value))
        [value]
    else if(value.element == highestValue)
        []
    else do {
        var neighbours: Array<ValuePoint> = valuesOfAdjacents(value.point)
        ---
        neighbours reduce ((lowPoint, accumulator = visited + value) -> (accumulator ++ basin(lowPoint, accumulator) distinctBy $ ))
    }

---
lowPoints map ((lowPoint) -> sizeOf(basin(lowPoint, []))) orderBy -$ take 3 reduce ((item, accumulator = 1) ->  item * accumulator)