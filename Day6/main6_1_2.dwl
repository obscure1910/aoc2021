%dw 2.0
import * from dw::core::Objects
output application/json

var fishes = (payload splitBy ",") groupBy $ mapObject ((value, key, index) -> {(key): sizeOf(value)})

fun setNewAgeOfFishes(fishes: Object): Object = 
    fishes mapObject ((fishCount, fishAge, index) -> 
        {
            (fishAge as Number -1): fishCount
        }        
    )

fun makeBabies(days: Number, fishes: Object): Object = 
    if(days == 0)
        fishes
    else do {
        var newAgesOfFishes = setNewAgeOfFishes(fishes)
        var toddlers = newAgesOfFishes."-1" as Number default 0
        ---
            makeBabies(days - 1,
                mergeWith(
                    newAgesOfFishes,
                    if(toddlers > 0) 
                        { 
                            "6": toddlers + (newAgesOfFishes."6" as Number default 0),
                            "8": toddlers
                        }
                    else
                        {}
                ) - "-1" // remove key "-1" from Object/Map
            )
    }        

fun populationAfterXDays(fishes: Object, days: Number) = sum(valueSet(makeBabies(days, fishes)) as Array<Number>)

---
//385391 Part1
//populationAfterXDays(fishes, 80)
//1728611055389 Part2
populationAfterXDays(fishes, 256)