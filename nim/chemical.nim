import tables
import macros
import sequtils
import strutils
import options

# My libraries
import unicode_numbers
import either

### ELEMENT INFO DEFINITION ###
type
    ElementName* = enum
        H = 1
        Li = 3
        B = 5
        C = 6
        N = 7
        O = 8
        Na = 11
        Mg = 12
        Al = 13
        Si = 14
        P = 15
        S = 16
        K = 19
        Sn = 50
    ElementInfo* = object
        charge*: seq[int]
        name*: ElementName
        fullName*: string
proc elementInfo(charge: seq[int], name: ElementName, fullName: string): ElementInfo =
    return ElementInfo(charge: charge, name: name, fullName: fullName)
proc getElementInfo(n: ElementName): ElementInfo =
    case n:
        of H:
            return elementInfo(@[1, -1], H, "Hydrogen")
        of Li:
            return elementInfo(@[1], Li, "Lithium")
        of B:
            return elementInfo(@[3], B, "Boron")
        of C:
            return elementInfo(@[4, -4], C, "Carbon")
        of N:
            return elementInfo(@[5, 3, -3], N, "Nitrogen")
        of O:
            return elementInfo(@[-2], O, "Oxygen")
        of Na:
            return elementInfo(@[1], Na, "Sodium")
        of Mg:
            return elementInfo(@[2], Mg, "Magnesium")
        of Al:
            return elementInfo(@[3], Al, "Aluminium")
        of Si:
            return elementInfo(@[4, -4], Si, "Silicon")
        of P:
            return elementInfo(@[5, 3, -3], P, "Phosphorus")
        of S:
            return elementInfo(@[6, 4, 2, -2], S, "Sulfur")
        of K:
            return elementInfo(@[1], K, "Potassium")
        of Sn:
            return elementInfo(@[4, 2, -4], Sn, "Tin")


### ELEMENT DEFINITION ###
type
    Element* = object
        name*: ElementName
        count*: Positive
        info*: ElementInfo
proc createElement(name: ElementName): Element =
    return Element(name: name, count: 1, info: name.getElementInfo())
proc createElement(name: ElementName, count: Positive): Element =
    return Element(name: name, count: count, info: name.getElementInfo())


### CHEMCIAL DEFINITION ###
type
    Chemical* = object
        elements*: seq[Either[Element, (Chemical, Positive)]]
proc `$`(x: Chemical): string =
    return
        x
        .elements
        .map(proc(elemChem: Either[Element, (Chemical, Positive)]): string =
            case elemChem.which:
            of leftKind:
                let c = elemChem.left
                if (c.count != 1):
                    return "$#$#" % [$ElementName(c.name), numberToSubscript(c.count)]
                else:
                    return $ElementName(c.name)
            of rightKind:
                let e = elemChem.right
                return "($#)$#" % [$(e[0]), numberToSubscript(e[1])]
        ).foldl("$#$#" % [a, b])


### REACTION DEFINITION ###
type
    Reaction* = object
        reactants*: seq[(Chemical, int)]
        products*: seq[(Chemical, int)]
proc isBalanced(reaction: Reaction): bool =
    proc getSeqTable(s: seq[(Chemical, int)]): TableRef[ElementName, int] =
        var quantityTable: TableRef[ElementName, int] = newTable[ElementName, int]()
        for _, chem in s.pairs():
            for _, el in chem[0].elements.pairs:
                case el.which:
                of leftKind:
                    discard quantityTable.hasKeyOrPut(ElementName(el[0].name), 0)
                of rightKind:
                    #TODO

    var quantityTable: TableRef[ElementName, int] = newTable[ElementName, int]()
    for _, chem in reaction.reactants.pairs():
        for _, el in chem[0].elements.pairs:
            discard quantityTable.hasKeyOrPut(ElementName(el.name), 0)
            quantityTable[ElementName(el.name)] += chem[1] * el.count
    for _, chem in reaction.products.pairs():
        for _, el in chem[0].elements.pairs:
            discard quantityTable.hasKeyOrPut(ElementName(el.name), 0)
            quantityTable[ElementName(el.name)] -= chem[1] * el.count
    for count in quantityTable.values:
        if count != 0:
            return false
    return true;
proc createReaction(reactants: openArray[(Chemical, int)], products: openArray[(Chemical, int)]): Option[Reaction] =
    let r: Reaction = Reaction(reactants: @reactants, products: @products)
    if not r.isBalanced():
        return none(Reaction)
    return some(r)

proc `$`(x: Reaction): string =
    let
        reactantString: string =
            x
            .reactants
            .map(proc(c: (Chemical, int)): string = $(c[0]))
            .foldl("$# + $#" % [a, b])
        productString: string =
            x
            .products
            .map(proc(c: (Chemical, int)): string = $(c[0]))
            .foldl("$# + $#" % [a, b])
    return (reactantString & " → " & productString)

# Just show a little test
when isMainModule:
    echo $createReaction(
        [
            (Chemical(elements: @[createElement(C), createElement(O,2)]), 2)
        ],
        [
            (Chemical(elements: @[createElement(C), createElement(O)]), 2),
            (Chemical(elements: @[createElement(O,2)]), 1)
        ]
    )
