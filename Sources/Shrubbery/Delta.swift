public protocol Delta {
    
    associatedtype Fork
    
    typealias Route = [Fork]
    
    func flow<A>(of: Route, as: A.Type) -> Flow<A>
}

extension Delta {
    
    @inlinable public func flow<A>(of route: Fork..., as: A.Type = A.self) -> Flow<A> {
        flow(of: Route(route), as: A.self)
    }
    
    @inlinable public subscript<A>(route: Fork..., as _: A.Type = A.self) -> Flow<A> {
        flow(of: Route(route), as: A.self)
    }
    
    @inlinable public subscript<A>(route: Route, as _: A.Type = A.self) -> Flow<A> {
        flow(of: route, as: A.self)
    }
}

extension Delta { // TODO: should these ↓ really be default where A: Equatable
    
    @inlinable func flow<A>(of  route: Route, as: A.Type) -> Flow<A> where A: Equatable {
        flow(of: route, as: A.self).removeDuplicates()
    }

    @inlinable public func flow<A>(of route: Fork..., as: A.Type = A.self) -> Flow<A> where A: Equatable {
        flow(of: Route(route), as: A.self).removeDuplicates()
    }

    @inlinable public subscript<A>(route: Fork..., as _: A.Type = A.self) -> Flow<A> where A: Equatable {
        flow(of: Route(route), as: A.self).removeDuplicates()
    }

    @inlinable public subscript<A>(route: Route, as _: A.Type = A.self) -> Flow<A> where A: Equatable {
        flow(of: route, as: A.self).removeDuplicates()
    }
}
