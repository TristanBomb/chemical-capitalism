type
    LRKind* = enum
        leftKind, rightKind
    Either*[L,R] = object
        case lr: LRKind
        of leftKind:
            left*: L
        of rightKind:
            right*: R

proc Left*[L,R](left: L): Either[L,R] =
    return Either(lr: leftKind, left: left)

proc Right*[L,R](right: R): Either[L,R] =
    return Either(lr: rightKind, right: right)

proc which*[L,R](e: Either[L,R]): LRKind =
    return e.lr

proc flatMap*[L,R,RPrime](e: Either[L,R], f: (proc (r: R): RPrime)): Either[L,RPrime] =
    case e.which
    of leftKind:
        return Left(e.left)
    of rightKind:
        return Right(f(e.right))
