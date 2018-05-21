import tables
import rationals

import chemical

# The parent concept for all resources in the game
type
    GameResource = object of RootObj
        units: string
        value: Rational[int]

# All the resources defined as types
type
    Money = ref object of GameResource
proc newMoney(): Money =
    return Money(units: "$", value: 0//1)

type
    Energy = ref object of GameResource
proc newEnergy(): Energy =
    return Energy(units: "kJ", value: 0//1)

type
    Science = ref object of GameResource
proc newScience(): Science =
    return Science(units: "Sci", value: 0//1)

# Value is meaningless for elements and compounds
type
    Elements = ref object of GameResource
        amount: Table[chemical.ElementName, int]
proc newElements(): Elements =
    return Elements(units: "$", value: 0//1, amount: initTable[chemical.ElementName, int]())

# Finally, the overall gamestate
type
    GameState = ref object
        money: Money
        energy: Energy
        science: Science
        elements: Elements
