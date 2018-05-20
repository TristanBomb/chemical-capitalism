import strutils

proc numberToSubscript*(n: int): string =
    let nums = [
        ("0", "₀"),
        ("1", "₁"),
        ("2", "₂"),
        ("3", "₃"),
        ("4", "₄"),
        ("5", "₅"),
        ("6", "₆"),
        ("7", "₇"),
        ("8", "₈"),
        ("9", "₉")
    ]
    return ($n).multiReplace(nums)