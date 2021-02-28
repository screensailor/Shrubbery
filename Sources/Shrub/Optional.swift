public func flattenOptionality<A>(of any: A) -> Any? {
    guard let o = any as? OptionalAny else {
        return any
    }
    return o.safelyUnwrapped
}

public func isNil<A>(_ any: A) -> Bool {
    switch flattenOptionality(of: any) {
    case .none: return true
    case .some: return false
    }
}

internal protocol OptionalAny: ExpressibleByNilLiteral {
    var safelyUnwrapped: Any? { get }
}

extension Optional: OptionalAny {

    var safelyUnwrapped: Any? {
        switch self
        {
        case .none:
            return self
            
        case .some(let o):
            guard let o = o as? OptionalAny else {
                return self
            }
            return o.safelyUnwrapped
        }
    }
}



