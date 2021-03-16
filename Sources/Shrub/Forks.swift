@dynamicMemberLookup
public struct Forks<Key>:
    Hashable,
    Collection,
    ExpressibleByArrayLiteral
where
    Key: Hashable
{
    public typealias Fork = EitherType<Int, Key>
    
    public var array: [Fork]
    
    public var startIndex: Int { array.startIndex }
    public var endIndex: Int { array.endIndex }
    
    public init(_ array: [Fork]) { self.array = array }
    
    public func __(_ i: Int) -> Self { Self(array + [^i]) }
    public func __(_ k: Key) -> Self { Self(array + [^k]) }
    
    public typealias Ints = (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)
    
    public subscript(dynamicMember i: KeyPath<Ints, Int>) -> Self {
        __(ints[keyPath: i])
    }

    public subscript(position: Int) -> Fork { array[position] }

    public func index(after i: Int) -> Int { array.index(after: i) }
    public func hash(into hasher: inout Hasher) { array.hash(into: &hasher) }
}

private let ints = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

extension Forks {
    
    public init(_ array: Fork...) {
        self.init(array)
    }
    
    public init(arrayLiteral elements: Fork...) {
        self.init(elements)
    }
}

extension Shrub {
    
    public subscript<A>(route: Forks<Key>, as type: A.Type = A.self) -> A? {
        get { self[route.array, as: A.self] }
        set { self[route.array, as: A.self] = newValue }
    }
}

