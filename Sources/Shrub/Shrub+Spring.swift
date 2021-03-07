extension Published.Publisher: Delta
where Value: Shrubbery
{
    public func stream<A>(of: [Value.Index], as: A.Type) -> Stream<A> {
        self // TODO:❗️check prefix instead of equatibility
            .map{ o in Result{ try o.get(of, as: A.self) } }
            .eraseToAnyPublisher()
    }
}

extension CurrentValueSubject: Delta
where
    Output: Shrubbery,
    Failure == Never
{
    public func stream<A>(of: [Output.Index], as: A.Type) -> Stream<A> {
        self
            .map{ o in Result{ try o.get(of, as: A.self) } }
            .eraseToAnyPublisher()
    }
}
