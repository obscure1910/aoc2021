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

fun playBingo(boards: Array<Array<Array<Field>>>, numbers: Array<Number>) = do {
    var newNumber = numbers[0] 
    var updatedBoards = boards map (updateBoard($, newNumber))
    var bingoBoards = updatedBoards map ((board, index) -> if(boardHasBingo(board)) index else -1)
    var indexBingoBoards = bingoBoards filter $ != -1

    ---
    if((sizeOf(numbers) == 1 and not isEmpty(indexBingoBoards)) or not isEmpty(indexBingoBoards))
        score(updatedBoards[indexBingoBoards[0]], newNumber)
    else if (sizeOf(numbers) == 1)
        "game over"
    else
        playBingo(updatedBoards, slice(numbers, 1, sizeOf(numbers)))
}

---
playBingo(inputBoards, inputNumbers)