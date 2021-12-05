%dw 2.0
import * from dw::util::Values
import * from dw::core::Objects
import * from dw::core::Arrays

output application/json

type Diagram = Array<Number>
type Point = {x: Number, y: Number}
type Line = {start: Point, end: Point}

@TailRec()
fun initArray(arr: Array<Number>, size: Number): Array<Number> =
    if(size == 0) arr else initArray(arr ++ [0], size -1)

fun toPoint(str: String): Point = do {
    var xy =  str splitBy ","
    ---
    {
        x: xy[0] as Number,
        y: xy[1] as Number
    }
}

fun toLine(points: Array<Point>): Line = 
    {
        start: points[0],
        end: points[1]
    }

var diagramSize = 10

var diagram: Diagram = initArray([], diagramSize * diagramSize)

var lines = splitBy(payload, "\n") map (splitBy($,"->") map trim($) map toPoint($)) map toLine($) 

fun drawPoint(point: Point, diagram: Diagram): Diagram = 
    diagram update { case n at [point.x + (point.y * diagramSize)] -> n + 1 }

fun drawLine(line: Line, diagram: Diagram): Diagram = do {
    var rangeX = (line.start.x to line.end.x) as Array<Number>
    var rangeY = (line.start.y to line.end.y) as Array<Number>

    ---
    if(sizeOf(rangeY) > 1 and sizeOf(rangeX) == 1)
        rangeY reduce ((ypos, d = diagram) -> drawPoint({x: rangeX[0], y: ypos} as Point, d)) //vertical
    else if(sizeOf(rangeX) > 1 and sizeOf(rangeY) == 1)
        rangeX reduce ((xpos, d = diagram) -> drawPoint({x: xpos, y: rangeY[0]} as Point, d)) //horizontal
    else
        diagram //diagonal
}

---
//5 if payload is input_example.txt
lines reduce ((line, d = diagram) -> drawLine(line, d)) countBy ($ > 1)
