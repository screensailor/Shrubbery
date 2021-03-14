extension Published.Publisher: Delta
where
    Value: Shrubbery
{
    /// Convenience. Not as performant as ``DeltaShrub``.
    public func flow<A>(of: [Value.Fork], as: A.Type = A.self) -> Flow<A> {
        self
            .map{ o in Result{ try o.get(of, as: A.self) } }
            .eraseToAnyPublisher()
    }
}

extension CurrentValueSubject: Delta
where
    Output: Shrubbery,
    Failure == Never
{
    /// Convenience. Not as performant as ``DeltaShrub``.
    public func flow<A>(of: [Output.Fork], as: A.Type = A.self) -> Flow<A> {
        self
            .map{ o in Result{ try o.get(of, as: A.self) } }
            .eraseToAnyPublisher()
    }
}
