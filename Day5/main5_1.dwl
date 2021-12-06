%dw 2.0
import * from dw::util::Values
import * from dw::core::Objects
import * from dw::core::Arrays

output application/json

type PointToHitMap = {} // "point.x" ++ "," ++ "point.y": hit count
type Point = {x: Number, y: Number}
type Line = {start: Point, end: Point}

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

var points: PointToHitMap = {}

var lines = splitBy(payload, "\n") map (splitBy($,"->") map trim($) map toPoint($)) map toLine($) 

fun drawPoint(point: Point, points: PointToHitMap): PointToHitMap = 
    points update { 
        case p at ."$(point.x ++ "," ++ point.y)"! -> if (p == null) 1 else (p as Number) + 1  
    }

fun drawLine(line: Line, points: PointToHitMap): PointToHitMap = do {
    var rangeX = (line.start.x to line.end.x) as Array<Number>
    var rangeY = (line.start.y to line.end.y) as Array<Number>

    ---
    if(sizeOf(rangeY) > 1 and sizeOf(rangeX) == 1)
        rangeY reduce ((ypos, p = points) -> drawPoint({x: rangeX[0], y: ypos} as Point, p)) //vertical
    else if(sizeOf(rangeX) > 1 and sizeOf(rangeY) == 1)
        rangeX reduce ((xpos, p = points) -> drawPoint({x: xpos, y: rangeY[0]} as Point, p)) //horizontal
    else
        points //diagonal
}

var gatheredPoints = lines reduce ((line, p = points) -> drawLine(line, p))

---
//6572
valuesOf(gatheredPoints) countBy $ > 1
