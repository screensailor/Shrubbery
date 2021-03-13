extension Published.Publisher: Delta
where Value: Shrubbery
{
    public func flow<A>(of: [Value.Index], as: A.Type = A.self) -> Flow<A> {
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
    public func flow<A>(of: [Output.Index], as: A.Type = A.self) -> Flow<A> {
        self
            .map{ o in Result{ try o.get(of, as: A.self) } }
            .eraseToAnyPublisher()
    }
}
