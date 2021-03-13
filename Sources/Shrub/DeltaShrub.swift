import Dispatch

public typealias DeltaJSON = DeltaShrub<String, JSONFragment>

public class DeltaShrub<Key, Value>: Delta where Key: Hashable, Key: Collection {
    
    public typealias Drop = Shrub<Key, Value>
    public typealias Fork = Drop.Index
    public typealias Route = [Fork]
    public typealias Result = Swift.Result<Drop, Error>
    public typealias Subscriptions = PassthroughSubject<Result, Never>
    
    private var drop: Drop
    private let scheduler: DispatchQueue
    private var subscriptions: Tree<Key, Subscriptions> = .init()

    public init(
        drop: Drop = nil,
        on scheduler: DispatchQueue = .init(
            label: "\(DeltaShrub<Key, Value>.self).q",
            qos: .userInteractive
        )
    ) {
        self.drop = drop
        self.scheduler = scheduler
    }
    
    public func get(_ route: Route) throws -> Drop {
        try drop.get(route)
    }
    
    public func set(_ route: Route, to value: Value) throws {
        try drop.set(value, at: route)
        
    }

    public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {
        
        fatalError()
    }
}

public class x_DeltaShrub<Key, Value>: Delta where Key: Hashable, Key: Collection {
    
    public typealias Drop = Shrub<Key, Value>
    public typealias Fork = Drop.Index
    public typealias Route = [Fork]
    
    @Published private var drop: Drop
    
    private lazy var routes = DefaultInsertingDictionary<Route, Flow<Drop>>(default: shared)
    
    private let scheduler: DispatchQueue

    public init(
        drop: Drop = nil,
        on scheduler: DispatchQueue = .init(
            label: "\(DeltaShrub<Key, Value>.self).q",
            qos: .userInteractive
        )
    ) {
        self.drop = drop
        self.scheduler = scheduler
    }
    
    @discardableResult
    public func sync(_ ƒ: (inout Drop) -> () = { _ in }) -> Drop {
        scheduler.sync{ ƒ(&drop); return drop }
    }

    public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {
        scheduler.sync {
            routes[route]
                .map{ o in Result{ try o.get().as(A.self) } }
                .merge(with: Just(Result{ try drop.get(route) } ))
                .subscribe(on: scheduler)
                .eraseToAnyPublisher()
        }
    }

    private func shared(_ route: Route) -> Flow<Drop> {
        $drop.map{ o in Result{ try o.get(route) } }// TODO:❗️filter
            .dropFirst()
            .multicast(subject: PassthroughSubject())
            .autoconnect()
            .eraseToAnyPublisher()
    }
}

