public protocol Delta: Routed {
    
    associatedtype DeltaFlow: Publisher where
        DeltaFlow.Output: Droplet,
        DeltaFlow.Failure == Never
    
    func flow(_ route: Route) -> DeltaFlow
}

extension Delta {

    @inlinable public func flow(_ route: Fork...) -> DeltaFlow {
        flow(route)
    }

    @inlinable public subscript(route: Fork...) -> DeltaFlow {
        flow(Route(route))
    }

    @inlinable public subscript(route: Route) -> DeltaFlow {
        flow(route)
    }
}

extension Delta {
    
    public typealias FlowOf<A> = Publishers.Map<DeltaFlow, Result<A, Error>>

    @inlinable public func flow<A>(_ route: Fork..., as: A.Type = A.self) -> FlowOf<A> {
        flow(route).cast()
    }

    @inlinable public func flow<A>(_ route: Route, as: A.Type = A.self) -> FlowOf<A> {
        flow(route).cast()
    }

    @inlinable public subscript<A>(route: Fork..., as _: A.Type = A.self) -> FlowOf<A> {
        flow(Route(route)).cast()
    }

    @inlinable public subscript<A>(route: Route, as _: A.Type = A.self) -> FlowOf<A> {
        flow(route).cast()
    }
}

extension Delta { // TODO: should these ↓ really be default where A: Equatable

    @inlinable func flow<A: Equatable>(_  route: Route, as: A.Type) -> Publishers.RemoveDuplicates<FlowOf<A>> {
        flow(route).cast(to: A.self).removeDuplicates()
    }

    @inlinable public func flow<A: Equatable>(_ route: Fork..., as: A.Type = A.self) -> Publishers.RemoveDuplicates<FlowOf<A>> {
        flow(Route(route)).cast(to: A.self).removeDuplicates()
    }

    @inlinable public subscript<A: Equatable>(route: Fork..., as _: A.Type = A.self) -> Publishers.RemoveDuplicates<FlowOf<A>> {
        flow(Route(route)).cast(to: A.self).removeDuplicates()
    }

    @inlinable public subscript<A: Equatable>(route: Route, as _: A.Type = A.self) -> Publishers.RemoveDuplicates<FlowOf<A>> {
        flow(route).cast(to: A.self).removeDuplicates()
    }
}
