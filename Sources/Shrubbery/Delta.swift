public protocol Delta {
    
    associatedtype DeltaFlow: Publisher where
        DeltaFlow.Output: Droplet,
        DeltaFlow.Failure == Never
    
    associatedtype Fork
    
    typealias Route = [Fork]
    
    func flow(of: Route) -> DeltaFlow
}

extension Publisher where Output: Droplet, Failure == Never {
    
    public func map<A>(_: A.Type = A.self) -> Flow<A> {
        map{ o in
            Result { () throws -> A in
                guard let r = try o.get() as? A else {
                    throw "\(type(of: o)) is not an \(A.self)"
                }
                return r
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Delta {

    @inlinable public func flow(of route: Fork...) -> DeltaFlow {
        flow(of: route)
    }

    @inlinable public subscript(route: Fork...) -> DeltaFlow {
        flow(of: Route(route))
    }

    @inlinable public subscript(route: Route) -> DeltaFlow {
        flow(of: route)
    }
}

extension Delta {

    @inlinable public func flow<A>(of route: Fork..., as: A.Type = A.self) -> Flow<A> {
        flow(of: route).map()
    }

    @inlinable public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {
        flow(of: route).map()
    }

    @inlinable public subscript<A>(route: Fork..., as _: A.Type = A.self) -> Flow<A> {
        flow(of: Route(route)).map(A.self)
    }

    @inlinable public subscript<A>(route: Route, as _: A.Type = A.self) -> Flow<A> {
        flow(of: route).map(A.self)
    }
}

extension Delta { // TODO: should these ↓ really be default where A: Equatable

    @inlinable func flow<A>(of  route: Route, as: A.Type) -> Flow<A> where A: Equatable {
        flow(of: route).map(A.self).removeDuplicates()
    }

    @inlinable public func flow<A>(of route: Fork..., as: A.Type = A.self) -> Flow<A> where A: Equatable {
        flow(of: Route(route)).map(A.self).removeDuplicates()
    }

    @inlinable public subscript<A>(route: Fork..., as _: A.Type = A.self) -> Flow<A> where A: Equatable {
        flow(of: Route(route)).map(A.self).removeDuplicates()
    }

    @inlinable public subscript<A>(route: Route, as _: A.Type = A.self) -> Flow<A> where A: Equatable {
        flow(of: route).map(A.self).removeDuplicates()
    }
}
