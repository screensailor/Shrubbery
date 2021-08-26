public protocol Delta: Routed {
    
    associatedtype Flow: Publisher where
        Flow.Output: Droplet,
        Flow.Failure == Never
    
    func flow(_ route: Route) -> Flow
}

extension Delta {

    @inlinable public func flow(_ route: Fork...) -> Flow {
        flow(route)
    }

    @inlinable public func flow(_ route: Key...) -> Flow {
        flow(^route)
    }

    @inlinable public func flow(_ route: [Key]) -> Flow {
        flow(^route)
    }
}

extension Delta {
    
    public typealias FlowAs<A> = Publishers.Map<Flow, Result<A, Error>>

    @inlinable public func flow<A>(_ route: Route, as: A.Type = A.self) -> FlowAs<A> {
        flow(route).cast()
    }

    @inlinable public func flow<A>(_ route: [Key], as: A.Type = A.self) -> FlowAs<A> {
        flow(^route).cast()
    }

    @inlinable public func flow<A>(_ route: Fork..., as: A.Type = A.self) -> FlowAs<A> {
        flow(route).cast()
    }

    @inlinable public func flow<A>(_ route: Key..., as: A.Type = A.self) -> FlowAs<A> {
        flow(^route).cast()
    }
}

extension Delta { // TODO: should these ↓ really be default where A: Equatable

    @inlinable func flow<A: Equatable>(_  route: Route, as: A.Type) -> Publishers.RemoveDuplicates<FlowAs<A>> {
        flow(route).cast(to: A.self).removeDuplicates()
    }

    @inlinable public func flow<A: Equatable>(_ route: Fork..., as: A.Type = A.self) -> Publishers.RemoveDuplicates<FlowAs<A>> {
        flow(Route(route)).cast(to: A.self).removeDuplicates()
    }
}
