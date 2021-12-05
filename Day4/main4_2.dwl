%dw 2.0
import * from dw::core::Arrays
output application/json

type Field = {
    number: Number,
    marked: Boolean
}

var inputNumbers: Array<Number> = payload splitBy "," map $ as Number
var inputBoards: Array<Array<Array<Field>>> = boardsInput splitBy "\r\n\r\n" 
    map ($ splitBy "\r\n" map ($ splitBy " " filter ($ != "") map (({number: $ as Number, marked: false}) as Field)))

fun updateField(field: Field, number: Number) =
    field update {
            //why - condition on field.number does not work after "at .marked"
            case m at .marked -> if (field.number == number) true else field.marked 
    }

fun updateRow(row: Array<Field>, number: Number): Array<Field> =
    row map (updateField($, number))

fun updateBoard(fields: Array<Array<Field>>, number: Number): Array<Array<Field>> = 
    fields map (updateRow($, number)) 

fun rowHasBingo(board: Array<Array<Field>>, index: Number): Boolean =
    board[index] every $.marked

fun columnHasBingo(board: Array<Array<Field>>, index: Number): Boolean = 
    sizeOf((board map $[index] filter $.marked)) == sizeOf(board)

fun boardHasBingo(board: Array<Array<Field>>): Boolean = do {
    var bingoRow: Boolean = board map ((item, index) -> rowHasBingo(board, index)) some $ == true
    var bingoColumn: Boolean = board map ((item, index) -> columnHasBingo(board, index)) some $ == true
    ---
    bingoRow or bingoColumn
}    

fun score(board: Array<Array<Field>>, calledNumber: Number) = sum(flatten(board) filter ($.marked == false) map $.number) * calledNumber

fun playBingo(boards: Array<Array<Array<Field>>>, numbers: Array<Number>, lastWinningBoard: Array<Array<Field>>, winningNumber: Number) = do {
    var newNumber = numbers[0] 
    var updatedBoards = boards map (updateBoard($, newNumber))
    var bingoBoards = updatedBoards filter boardHasBingo($)
    var newLastWinningBoard = bingoBoards[0] default lastWinningBoard
    var newWinningNumber = if(newLastWinningBoard != lastWinningBoard) newNumber else winningNumber
    ---
    if(sizeOf(numbers) == 1 and not isEmpty(lastWinningBoard[0]))
        score(lastWinningBoard, winningNumber)
    else if (sizeOf(numbers) == 1)
        "game over"
    else
        playBingo(updatedBoards -- bingoBoards, slice(numbers, 1, sizeOf(numbers)), newLastWinningBoard, newWinningNumber)
}

fun playBingo(boards: Array<Array<Array<Field>>>, numbers: Array<Number>) = playBingo(boards, numbers, [[]], -1)

---
playBingo(inputBoards, inputNumbers)