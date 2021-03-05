extension Published.Publisher: Spring
where Value: Shrubbery
{
    public typealias Index = Value.Index
    
    public func stream<A>(of: [Index], as: A.Type) -> Stream<A> {
        self // TODO:❗️check prefix instead of equatibility
            .map{ o in Result{ try o.get(of, as: A.self) } }
            .eraseToAnyPublisher()
    }
}

extension CurrentValueSubject: Spring
where
    Output: Shrubbery,
    Failure == Never
{
    public typealias Index = Output.Index
    
    public func stream<A>(of: [Index], as: A.Type) -> Stream<A> {
        self
            .map{ o in Result{ try o.get(of, as: A.self) } }
            .eraseToAnyPublisher()
    }
}
