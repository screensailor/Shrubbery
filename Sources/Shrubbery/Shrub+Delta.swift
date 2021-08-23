extension Publisher where Output: Shrubbery {
    public typealias Key = Output.Key
    /**
     Convenience. Not as performant as `DeltaShrub`.
     */
    public func flow(_ route: Output.Route) -> Publishers.Map<Self, Result<Any?, Error>> {
        map{ o in Result{ try o.get(route).unwrapped } }
    }
}

extension Published.Publisher: Routed, Delta where Output: Shrubbery {}
extension CurrentValueSubject: Routed, Delta where Output: Shrubbery, Failure == Never {}
extension PassthroughSubject: Routed, Delta where Output: Shrubbery, Failure == Never {}

