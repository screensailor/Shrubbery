@dynamicMemberLookup
public struct I<Key>: Hashable, Collection where Key: Hashable {
    
    public typealias Element = EitherType<Int, Key>
    
    public var array: [Element]
    
    public var startIndex: Int { array.startIndex }
    public var endIndex: Int { array.endIndex }
    
    public init(_ array: Element...) { self.init(array) }
    public init(_ array: [Element]) { self.array = array }
    
    public func __(_ i: Int) -> Self { Self(array + [^i]) }
    public func __(_ k: Key) -> Self { Self(array + [^k]) }
    
    public subscript(dynamicMember i: KeyPath<(Int, Int, Int), Int>) -> Self {
        let int = (0, 1, 2)
        return __(int[keyPath: i])
    }

    public subscript(position: Int) -> Element { array[position] }

    public func index(after i: Int) -> Int { array.index(after: i) }
    public func hash(into hasher: inout Hasher) { array.hash(into: &hasher) }
}

extension Shrub {
    
    public subscript<A>(route: I<Key>, as type: A.Type = A.self) -> A? {
        get { self[route.array, as: A.self] }
        set { self[route.array, as: A.self] = newValue }
    }
}

// TODO:❗️use instead of Shrubbery.Route
//@dynamicMemberLookup
//public struct Route<Key>: Hashable, Collection where Key: Hashable {
//
//    public typealias Fork = EitherType<Int, Key>
//
//    public var array: [Fork]
//
//    public var startIndex: Int { array.startIndex }
//    public var endIndex: Int { array.endIndex }
//
//    public init(_ array: Fork...) { self.init(array) }
//    public init(_ array: [Fork]) { self.array = array }
//
//    public func __(_ i: Int) -> Self { Self(array + [^i]) }
//    public func __(_ k: Key) -> Self { Self(array + [^k]) }
//
//    public subscript(dynamicMember i: KeyPath<(Int, Int, Int), Int>) -> Self {
//        let int = (0, 1, 2)
//        return __(int[keyPath: i])
//    }
//
//    public subscript(position: Int) -> Fork { array[position] }
//
//    public func index(after i: Int) -> Int { array.index(after: i) }
//    public func hash(into hasher: inout Hasher) { array.hash(into: &hasher) }
//}
//
//extension Shrub {
//
//    public subscript<A>(route: Route<Key>, as type: A.Type = A.self) -> A? {
//        get { self[route.array, as: A.self] }
//        set { self[route.array, as: A.self] = newValue }
//    }
//}
