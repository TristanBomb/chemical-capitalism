import strutils

proc `$`[T](x: Ordinal[T]): string =
    return $int(x)

proc toSubscript*(num: Ordinal | float): string =
    ## Convert a number to a string written in subscript (below the line).
    let nums = {
        "0": "₀",
        "1": "₁",
        "2": "₂",
        "3": "₃",
        "4": "₄",
        "5": "₅",
        "6": "₆",
        "7": "₇",
        "8": "₈",
        "9": "₉",
        "-": "₋",
        "+": "₊",
        ".": "."
    }
    return ($num).multiReplace(nums)

proc toSuperscript*(num: Ordinal | float): string =
    ## Convert a number to a string written in superscript (above the line).
    let nums = {
        "0": "₀",
        "1": "¹",
        "2": "²",
        "3": "³",
        "4": "⁴",
        "5": "⁵",
        "6": "⁶",
        "7": "⁷",
        "8": "⁸",
        "9": "⁹",
        "-": "⁻",
        "+": "⁺",
        ".": "⋅"
    }
    return ($num).multiReplace(nums)
