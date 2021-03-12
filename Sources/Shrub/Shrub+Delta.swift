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

// MARK: DeltaShrub

public typealias DeltaJSON = DeltaShrub<String, JSONFragment>

public class DeltaShrub<Key, Value>: Delta where Key: Hashable {
    
    public typealias Drop = Shrub<Key, Value>
    public typealias Fork = Drop.Index
    public typealias Route = [Fork]
    
    @Published public var store: Shrub<Key, Value> = nil
    
    private lazy var routes = DefaultInsertingDictionary<Route, Flow<Drop>>(default: shared)
    
    public init(_ store: Shrub<Key, Value> = nil) {
        self.store = store
    }
    
    private func shared(_ route: Route) -> Flow<Drop> {
        $store.map{ o in Result{ try o.get(route, as: Drop.self) } }
            .dropFirst()
            .multicast(subject: PassthroughSubject())
            .autoconnect()
            .eraseToAnyPublisher()
    }
    
    public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {
        routes[route]
            .map{ o in Result{ try o.get().as(A.self) } }
            .merge(with: Just(Result{ try store.get(route, as: A.self) } ))
            .eraseToAnyPublisher()
    }
}
