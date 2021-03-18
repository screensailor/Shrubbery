public protocol Delta {
    
    associatedtype Fork
    
    typealias Route = [Fork]
    
    func flow<A>(of: Route, as: A.Type) -> Flow<A>
}

extension Delta {
    
    public func flow<A>(of route: Fork..., as: A.Type = A.self) -> Flow<A> {
        self.flow(of: Route(route), as: A.self)
    }
    
    public subscript<A>(route: Fork..., as _: A.Type = A.self) -> Flow<A> {
        self.flow(of: Route(route), as: A.self)
    }
    
    public subscript<A>(route: Route, as _: A.Type = A.self) -> Flow<A> {
        self.flow(of: route, as: A.self)
    }
}

