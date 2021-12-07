%dw 2.0

output application/json

var crabs = payload splitBy "," map $ as Number orderBy $

fun costOfFuelToMoveCrabToPosition(currentPos: Number, targetPos: Number): Number = abs(targetPos - currentPos)
fun overallCostsOfFuel(crabs: Array<Number>): Number = sum(crabs)

---
crabs reduce ((crab, lowestCostsOfFuel=10000000) -> do {
    var fuels = crabs map costOfFuelToMoveCrabToPosition($, crab)
    var overallCosts = overallCostsOfFuel(fuels)
    ---
    if(lowestCostsOfFuel > overallCosts) overallCosts else lowestCostsOfFuel
})