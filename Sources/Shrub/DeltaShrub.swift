import Dispatch

public class DeltaShrub<Key>: Delta /* TODO:❗️, Shrubbery */ where Key: Hashable {
    
    public typealias Drop = Shrub<Key>
    public typealias Fork = Drop.Fork
    public typealias Subject = PassthroughSubject<Result<Drop, Error>, Never>
    
    private var drop: Drop
    private let queue: DispatchQueue // TODO: a more generic Scheduler
    private var subscriptions: Tree<Fork, Subject>

    public init(
        drop: Drop = nil,
        on queue: DispatchQueue = .init(
            label: "\(DeltaShrub<Key>.self).q",
            qos: .userInteractive
        ),
        subscriptions: Tree<Fork, Subject> = .init()
    ) {
        self.drop = drop
        self.queue = queue
        self.subscriptions = subscriptions
    }
}

extension DeltaShrub {
    
    public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {
        Just(Result{ try get(route) }).merge(
            with: subscriptions[value: route, inserting: Subject()].map{ o in
                Result{ try o.get().as(A.self) }
            }
        )
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }
}

extension DeltaShrub {
    
    public func get<A>(_ route: Fork...) throws -> A {
        try get(route)
    }
    
    public func get<A, Route>(_ route: Route) throws -> A
    where
        Route: Collection,
        Route.Element == Fork
    {
        try queue.sync{ try drop.get(route) }
    }
}

extension DeltaShrub {

    public func set<A>(_ route: Fork..., to value: A) throws {
        try set(route, to: value)
    }
    
    public func set<A, Route>(_ route: Route, to value: A) throws
    where
        Route: Collection,
        Route.Element == Fork
    {
        try queue.sync{
            try drop.set(route, to: value)
            subscriptions[route]?.traverse{ subroute, subject in
                subject?.send(Result{ try drop.get(route + subroute) })
            }
        }
    }
}

extension DeltaShrub {

    public func set<A>(_ route: Fork..., to value: Result<A, Error>) {
        set(route, to: value)
    }
    
    public func set<A, Route>(_ route: Route, to value: Result<A, Error>)
    where
        Route: Collection,
        Route.Element == Fork
    {
        queue.sync{
            do {
                let value = try value.get()
                try drop.set(route, to: value)
                subscriptions[route]?.traverse{ subroute, subject in
                    subject?.send(Result{ try drop.get(route + subroute) })
                }
            }
            catch {
                drop.delete(route) // TODO:❗️store error for new subscribers (is using current value subject worth it?)
                subscriptions[route]?.traverse{ subroute, subject in
                    subject?.send(.failure(error))
                }
            }
        }
    }
}

extension DeltaShrub: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        "Delta" + drop.debugDescription
    }
}
