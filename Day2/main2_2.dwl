%dw 2.0
output application/json

type Forward = "forward"
type Down    = "down"
type Up      = "up"
type Direction = Forward | Down | Up 
type Command = {
    direction: Direction,
    step: Number
}
type Position = {
    horizontal: Number,
    depth: Number,
    aim: Number
}

fun move(position: Position, command: Command): Position = (
    command.direction match {
        case is Forward -> position update {
                                case h at .horizontal -> h + command.step
                                case d at .depth      -> d + (position.aim * command.step)
                           }
        case is Down    -> position update { case a at .aim -> a + command.step}
        case is Up      -> position update { case a at .aim -> a - command.step}
    }
)

var commands: Array<Command> = payload splitBy "\n" map splitBy($, " ") map ({direction: $[0] as Direction, step: $[1] as Number})

var startPosition: Position = {
        horizontal: 0,
        depth: 0,
        aim: 0   
    }

var finalPosition = commands reduce ((command, position = startPosition) -> move(position, command)) 

---

finalPosition.horizontal * finalPosition.depth