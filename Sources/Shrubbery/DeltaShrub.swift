import Foundation

public class DeltaShrub<Key>: Delta where Key: Hashable {
    
    public typealias Subject = PassthroughSubject<Result<Any?, Error>, Never>
    
    public private(set) var shrub: Shrub<Key>
    private var subscriptions: Tree<Fork, Subject>
    private let lock = Lock()

    public init(
        drop: Shrub<Key> = nil,
        subscriptions: Tree<Fork, Subject> = .init()
    ) {
        self.shrub = drop
        self.subscriptions = subscriptions
    }

    public convenience init(_ unwrapped: Any) {
        self.init(drop: Shrub<Key>(unwrapped))
    }
    
    // MARK: sync

    func sync<A>(_ work: () throws -> A) rethrows -> A {
        lock.lock()
        defer{ lock.unlock() }
        return try work()
    }

    // MARK: delta flow

    public func flow(_ route: Route) -> AnyPublisher<Result<Any?, Error>, Never> {
        sync {
            Just(Result{ try shrub.get(route) }).merge(
                with: subscriptions[value: route, inserting: Subject()]
            )
            .eraseToAnyPublisher()
        }
    }

    // MARK: get

    public func get<A>(_ route: Fork...) throws -> A {
        try get(route)
    }

    public func get<A, Route>(_ route: Route) throws -> A
    where
        Route: Collection,
        Route.Element == Fork
    {
        try sync{ try shrub.get(route) }
    }

    // MARK: set

    public func reset(to unwrapped: Any? = nil) {
        set([], to: .success(unwrapped))
    }

    public func set<A>(_ route: Fork..., to value: A) {
        set(route, to: value)
    }

    public func set<A, Route>(_ route: Route, to value: A)
    where
        Route: Collection,
        Route.Element == Fork
    {
        sync{
            shrub.set(route, to: value)
            for route in route.lineage.reversed() {
                subscriptions[route]?.value?.send(Result{ try shrub.get(route) })
            }
            subscriptions[route]?.traverse{ subroute, subject in
                subject?.send(Result{ try shrub.get(route + subroute) })
            }
        }
    }

    public func set<A>(_ route: Fork..., to value: Result<A, Error>) {
        set(route, to: value)
    }

    public func set<A, Route>(_ route: Route, to value: Result<A, Error>)
    where
        Route: Collection,
        Route.Element == Fork
    {
        sync{
            do {
                try set(route, to: value.get())
            } catch {
                delete(route, because: error)
            }
        }
    }

    // MARK: delete

    public func delete(_ route: Fork..., because error: Error? = nil) {
        delete(route, because: error)
    }

    public func delete<Route>(_ route: Route, because error: Error? = nil)
    where
        Route: Collection,
        Route.Element == Fork
    {
        sync{
            shrub.delete(route)
            for route in route.lineage.reversed() {
                subscriptions[route]?.value?.send(Result{ try shrub.get(route) })
            }
            let error: Result<Any?, Error> = .failure(error ?? "Route '\(route)' has been deleted")
            subscriptions[route]?.traverse{ subroute, subject in
                subject?.send(error)
            }
        }
    }
}

extension DeltaShrub {

    public func batch() -> Batch {
        Batch()
    }

    public func apply(_ batch: Batch) {
        sync {
            shrub.merge(batch.shrub)
            var routes: [[Fork]: Subject] = [:]
            for route in batch.routes {
                for route in route.lineage.reversed() {
                    routes[route.array] = subscriptions[route]?.value
                }
                subscriptions[route]?.traverse{ subroute, subject in
                    routes[route + subroute] = subject
                }
            }
            for (route, subject) in routes.sorted(by: { a, b in a.key.count < b.key.count }) {
                subject.send(Result{ try shrub.get(route) })
            }
        }
    }

    public struct Batch: Shrubbery {

        public private(set) var routes: Set<[Fork]> = []
        public private(set) var shrub: Shrub<Key>
        
        public var unwrapped: Any? {
            shrub.unwrapped
        }

        public init(_ unwrapped: Any?) {
            shrub = Shrub(unwrapped)
        }

        public init(_ shrub: Shrub<Key>) {
            self.shrub = shrub
        }

        public func get(_ route: Route) throws -> Batch {
            try Batch(shrub.get(route))
        }

        public mutating func set(_ route: Route, to value: Any?) {
            shrub.set(route, to: value)
            routes.insert(route)
        }

        public mutating func delete(_ route: Route) {
            shrub.set(route, to: Sentinel.deletion)
            routes.insert(route)
        }
    }
}

extension DeltaShrub: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        "Delta" + shrub.debugDescription
    }
}

private extension Collection {

    var lineage: AnySequence<SubSequence> {
        AnySequence(sequence(first: dropLast()){ $0.dropLast().ifNotEmpty })
    }
}
