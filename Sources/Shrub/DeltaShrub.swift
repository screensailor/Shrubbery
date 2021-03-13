import Peek
import Dispatch

public typealias DeltaJSON = DeltaShrub<String, JSONFragment>

public class DeltaShrub<Key, Value>: Delta where Key: Hashable, Key: Collection {
    
    public typealias Drop = Shrub<Key, Value>
    public typealias Fork = Drop.Index
    public typealias Route = [Fork]
    public typealias Result = Swift.Result<Drop, Error>
    public typealias Subject = PassthroughSubject<Result, Never>
    
    private var drop: Drop
    private let queue: DispatchQueue
    private var subjects: Tree<Fork, Subject>

    public init(
        drop: Drop = nil,
        on queue: DispatchQueue = .init(
            label: "\(DeltaShrub<Key, Value>.self).q",
            qos: .userInteractive
        ),
        subjects: Tree<Fork, Subject> = .init()
    ) {
        self.drop = drop
        self.queue = queue
        self.subjects = subjects
    }
    
    public func get<A>(_ route: Fork...) throws -> A {
        try get(route)
    }
    
    public func get<A, Route>(_ route: Route) throws -> A
    where
        Route: Collection,
        Route.Element == Fork
    {
        try drop.get(route, as: A.self)
    }
    
    public func set<A>(_ route: Fork..., to value: A) throws {
        try set(route, to: value)
    }
    
    public func set<A, Route>(_ route: Route, to value: A) throws
    where
        Route: Collection,
        Route.Element == Fork
    {
        try drop.set(value, at: route)
        subjects[route]?.traverse { subroute, subject in
            subject?.send(Result{ try drop.get(route + subroute) })
        }
    }

    public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {
        let subject = subjects[value: route] ?? {
            let o = Subject()
            subjects[value: route] = o
            return o
        }()
        return Just(Swift.Result{ try drop.get(route) })
            .merge(with: subject.map{ o in Swift.Result{ try o.get().as(A.self) } })
            .eraseToAnyPublisher()
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

