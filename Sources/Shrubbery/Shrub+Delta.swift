extension Publisher where Output: Shrubbery {
    /**
     Convenience. Not as performant as `DeltaShrub`.
     */
    public func flow(of route: Output.Route) -> Publishers.Map<Self, Result<Any?, Error>> {
        map{ o in Result{ try o.get(route).unwrapped } }
    }
}

extension Published.Publisher: Delta where Output: Shrubbery {}
extension CurrentValueSubject: Delta where Output: Shrubbery, Failure == Never {}
extension PassthroughSubject: Delta where Output: Shrubbery, Failure == Never {}

