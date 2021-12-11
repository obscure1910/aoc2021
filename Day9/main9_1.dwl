%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Objects

output application/json

type Point = {
    x: Number,
    y: Number
}

type AdjacentPoints = {
    top: Point | Null,
    right: Point | Null,
    down: Point | Null,
    left: Point | Null
}

type AdjacentElements = {
    top: Number | Null,
    right: Number | Null,
    down: Number | Null,
    left: Number | Null
}

var matrix = splitBy(payload, "\n") map($ splitBy "" map $ as Number)
var upperBoundX = sizeOf(matrix[0]) - 1
var upperBoundY = sizeOf(matrix) - 1
var riskLevel = 1

fun nullIfOutOfBounds(p: Point): Point | Null =
    if (p.x < 0 or p.y < 0 or p.x > upperBoundX or p.y > upperBoundY)
        null
    else 
        p

fun coordsOfAdjacents(p: Point): AdjacentPoints = 
    {
        top:   nullIfOutOfBounds({x: p.x, y: p.y + 1 }),
        right: nullIfOutOfBounds({x: p.x + 1, y: p.y}),
        down:  nullIfOutOfBounds({x: p.x, y: p.y - 1 }),
        left:  nullIfOutOfBounds({x: p.x - 1, y: p.y})
    }

fun elementsOfAdjacents(a: AdjacentPoints): AdjacentElements =
    {
        top: a.top  match {
            case top is Point -> matrix[top.y][top.x]
            else -> null
        },
        right: a.right match {
            case right is Point -> matrix[right.y][right.x]
            else -> null
        },
        down: a.down match {
            case down is Point -> matrix[down.y][down.x] 
            else -> null
        },
        left: a.left match {
            case left is Point -> matrix[left.y][left.x]
            else -> null
        }
    }

var minis = (matrix flatMap ((row, y) -> 
    row map ((column, x) -> do {
        var element = matrix[y][x]
        var coords = coordsOfAdjacents({x: x, y: y})
        var values = valuesOf(elementsOfAdjacents(coords)) - null
        var minimum = min([element] ++ values)
        ---
        if(minimum == element and !contains(values, element)) element + riskLevel else null
    })
)) - null

---
sum(minis)


