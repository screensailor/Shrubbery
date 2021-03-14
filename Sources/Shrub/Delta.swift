public protocol Delta {
    associatedtype Fork
    typealias Route = [Fork]
    func flow<A>(of: Route, as: A.Type) -> Flow<A>
}

extension Delta {
    
    public subscript<A>(of: Route, as _: A.Type = A.self) -> Flow<A> {
        self.flow(of: of, as: A.self)
    }
}

extension Delta {
    
    public func flow<A>(of: Fork..., as: A.Type = A.self) -> Flow<A> {
        self.flow(of: Route(of), as: A.self)
    }
    
    public subscript<A>(of: Fork..., as _: A.Type = A.self) -> Flow<A> {
        self.flow(of: Route(of), as: A.self)
    }
}

