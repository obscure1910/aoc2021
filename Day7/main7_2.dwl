%dw 2.0

output application/json

var initialCrabsPosition = payload splitBy "," map $ as Number orderBy $

fun partialSum(n: Number): Number = n * (n + 1) / 2
fun costOfFuelToMoveCrabToPosition(currentPos: Number, targetPos: Number): Number = partialSum(abs(targetPos - currentPos))
fun overallCostsOfFuel(crabs: Array<Number>): Number = sum(crabs)

fun calculateLowestCosts(crabs: Array<Number>): Number = 
    crabs reduce ((crab, lowestCostsOfFuel=999999999) -> do {
        var fuels = crabs map costOfFuelToMoveCrabToPosition($, crab)
        var overallCosts = overallCostsOfFuel(fuels)
        ---
        if(lowestCostsOfFuel >= overallCosts) overallCosts else lowestCostsOfFuel
    })

---

calculateLowestCosts(initialCrabsPosition)
