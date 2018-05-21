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
    ElementQuantities* = TableRef[ElementName, int]
proc createChemical(elements: seq[Either[Element, (Chemical, Positive)]]): Chemical =
    return Chemical(elements: elements)
proc elemChem(eC: ElementName): Either[Element, (Chemical, Positive)] =
    return Left[Element, (Chemical, Positive)](createElement(eC))
proc elemChem(eC: ElementName, n: Positive): Either[Element, (Chemical, Positive)] =
    return Left[Element, (Chemical, Positive)](createElement(eC, n))
proc elemChem(eC: Chemical, n: Positive): Either[Element, (Chemical, Positive)] =
    return Right[Element, (Chemical, Positive)]((eC, n))
proc `$`(x: Chemical): string =
    return
        x
        .elements
        .map(proc(elemChem: Either[Element, (Chemical, Positive)]): string =
            case elemChem.which:
            of leftKind:
                let c = elemChem.left
                if (c.count != 1):
                    return "$#$#" % [$ElementName(c.name), c.count.toSubscript()]
                else:
                    return $ElementName(c.name)
            of rightKind:
                let e = elemChem.right
                return "($#)$#" % [$(e[0]), e[1].toSubscript()]
        ).foldl("$#$#" % [a, b])
proc getElementQuantities(c: Chemical): ElementQuantities =
    let quantityTable = newTable[ElementName, int]()
    for _, elemChem in c.elements.pairs():
        discard quantityTable[].hasKeyOrPut(elemChem.left.name, 0)
        case elemChem.which
        of leftKind:
            quantityTable[elemChem.left.name] += elemChem.left.count
        of rightKind:
            let recursiveTable = getElementQuantities(elemChem.right[0])
            for name, quantity in recursiveTable.pairs():
                discard quantityTable[].hasKeyOrPut(name, 0)
                quantityTable[name] += quantity * elemChem.right[1]
    return quantityTable

### REACTION DEFINITION ###
type
    Reaction* = object
        reactants*: seq[(Chemical, int)]
        products*: seq[(Chemical, int)]
proc isBalanced(reaction: Reaction): bool =
    proc mulAddMergeTables[A](a: TableRef[A,int], b: TableRef[A,int], m: int) =
        for k, v in b.pairs():
            if not a.hasKey(k):
                a[k] = 0
            a[k] += v * m

    var quantityTable: TableRef[ElementName, int] = newTable[ElementName, int]()
    for chem in reaction.reactants.items():
        quantityTable.mulAddMergeTables(getElementQuantities(chem[0]), chem[1])
    for chem in reaction.products.items():
        quantityTable.mulAddMergeTables(getElementQuantities(chem[0]), -chem[1])
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
            (createChemical(@[elemChem(C), elemChem(O,2)]), 2)
        ],
        [
            (createChemical(@[elemChem(C), elemChem(O)]), 2),
            (createChemical(@[elemChem(O,2)]), 1)
        ]
    )
