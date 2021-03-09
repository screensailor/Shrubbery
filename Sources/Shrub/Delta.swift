extension Delta {
    
    public subscript<A>(of: Key, as _: A.Type = A.self) -> Flow<A> {
        self.flow(of: of, as: A.self)
    }
}

extension Delta where Key: RangeReplaceableCollection {
    
    public func flow<A>(of: Key.Element..., as: A.Type = A.self) -> Flow<A> {
        self.flow(of: Key(of), as: A.self)
    }
    
    public subscript<A>(of: Key.Element..., as _: A.Type = A.self) -> Flow<A> {
        self.flow(of: Key(of), as: A.self)
    }
}

