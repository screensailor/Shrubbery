public protocol Spring {
    associatedtype Key: Hashable
    func stream<A>(of: Key, as: A.Type) -> Stream<A>
}

extension Spring where Key: RangeReplaceableCollection {
    
    public func stream<A>(of: Key.Element..., as: A.Type = A.self) -> Stream<A> {
        self.stream(of: Key(of), as: A.self)
    }
}

