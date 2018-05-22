import tables
import rationals
import dom
import sequtils
import strutils

import chemical_capitalismpkg/chemical

# The parent concept for all resources in the game
type
    GameResource = ref object of RootObj
        units: string
        value: Rational[int]
proc `$`(x: GameResource): string =
    return "Resource with units $# and value $#" % [$x.units, $x.value]

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
proc `$`(x: GameState): string =
    return (
        """State(
            money:    $#
            energy:   $#
            science:  $#
            elements: $#
        )""" % [$x.money, $x.energy, $x.science, $x.elements]
    )

when isMainModule:
    let state: GameState = GameState(money: newMoney(), energy: newEnergy(), science: newScience(), elements: newElements())
    window.alert($state)
