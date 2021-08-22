public protocol Delta: Routed {
    
    associatedtype DeltaFlow: Publisher where
        DeltaFlow.Output: Droplet,
        DeltaFlow.Failure == Never
    
    func flow(of: Route) -> DeltaFlow
}

public protocol Flows: Publisher where Output: Droplet, Failure == Never {}

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
    
    public typealias FlowOf<A> = Publishers.Map<DeltaFlow, Result<A, Error>>

    @inlinable public func flow<A>(of route: Fork..., as: A.Type = A.self) -> FlowOf<A> {
        flow(of: route).cast()
    }

    @inlinable public func flow<A>(of route: Route, as: A.Type = A.self) -> FlowOf<A> {
        flow(of: route).cast()
    }

    @inlinable public subscript<A>(route: Fork..., as _: A.Type = A.self) -> FlowOf<A> {
        flow(of: Route(route)).cast()
    }

    @inlinable public subscript<A>(route: Route, as _: A.Type = A.self) -> FlowOf<A> {
        flow(of: route).cast()
    }
}

extension Delta { // TODO: should these ↓ really be default where A: Equatable
    
    public typealias WithoutDuplicatesFlowOf<A> = Publishers.RemoveDuplicates<Publishers.Map<DeltaFlow, Result<A, Error>>>

    @inlinable func flow<A: Equatable>(of  route: Route, as: A.Type) -> WithoutDuplicatesFlowOf<A> {
        flow(of: route).cast(to: A.self).removeDuplicates()
    }

    @inlinable public func flow<A: Equatable>(of route: Fork..., as: A.Type = A.self) -> WithoutDuplicatesFlowOf<A> {
        flow(of: Route(route)).cast(to: A.self).removeDuplicates()
    }

    @inlinable public subscript<A: Equatable>(route: Fork..., as _: A.Type = A.self) -> WithoutDuplicatesFlowOf<A> {
        flow(of: Route(route)).cast(to: A.self).removeDuplicates()
    }

    @inlinable public subscript<A: Equatable>(route: Route, as _: A.Type = A.self) -> WithoutDuplicatesFlowOf<A> {
        flow(of: route).cast(to: A.self).removeDuplicates()
    }
}
