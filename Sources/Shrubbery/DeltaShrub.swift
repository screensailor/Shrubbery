import Dispatch

public class DeltaShrub<Key>: Delta /* TODO:❗️, Shrubbery */ where Key: Hashable {
    
    public typealias Fork = Shrub<Key>.Fork
    public typealias Subject = PassthroughSubject<Result<Shrub<Key>, Error>, Never>
    
    public private(set) var shrub: Shrub<Key>
    private var subscriptions: Tree<Fork, Subject>

    private let k: DispatchSpecificKey<Void>
    private let q: DispatchQueue = .init(
        label: "\(DeltaShrub<Key>.self).q_\(#file)_\(#line)",
        qos: .userInteractive
    )

    public init(
        drop: Shrub<Key> = nil,
        subscriptions: Tree<Fork, Subject> = .init()
    ) {
        self.shrub = drop
        self.subscriptions = subscriptions
        self.k = q.setSpecificKey()
    }

    public convenience init(_ unwrapped: Any) {
        self.init(drop: Shrub<Key>(unwrapped))
    }

    func sync<A>(_ work: () throws -> A) rethrows -> A {
        DispatchQueue.getSpecific(key: k) == nil
            ? try q.sync(execute: work)
            : try work()
    }

    // MARK: delta flow

    public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {
        sync{
            Just(Result{ try shrub.get(route) }).merge(
                with: subscriptions[value: route, inserting: Subject()].map{ o in
                    Result{ try o.get().as(A.self) }
                }
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

    public func set<A>(_ route: Fork..., to value: A) throws {
        try set(route, to: value)
    }

    public func set<A, Route>(_ route: Route, to value: A) throws
    where
        Route: Collection,
        Route.Element == Fork
    {
        try sync{
            try shrub.set(route, to: value)
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
            let error: Result<Shrub<Key>, Error> = .failure(error ?? "Route '\(route)' has been deleted")
            subscriptions[route]?.traverse{ subroute, subject in
                subject?.send(error)
            }
        }
    }
}

extension DeltaShrub {

    public func transaction() -> Transaction {
        Transaction()
    }

    public func apply(_ transaction: Transaction) {
        sync {
            shrub.merge(transaction.shrub)
            var routes: [[Fork]: Subject] = [:]
            for route in transaction.routes {
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

    public class Transaction: DeltaShrub {

        fileprivate var routes: Set<[Fork]> = []

        fileprivate init() {}

        public override func set<A, Route>(_ route: Route, to value: A) throws
        where
            Route: Collection,
            Route.Element == Fork
        {
            try sync{
                try super.set(route, to: value)
                routes.insert(route.array)
            }
        }

        public override func delete<Route>(_ route: Route, because error: Error? = nil)
        where
            Route: Collection,
            Route.Element == Fork
        {
            sync{
                do {
                    try super.set(route, to: Sentinel.deletion)
                    routes.insert(route.array)
                } catch {}
            }
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
