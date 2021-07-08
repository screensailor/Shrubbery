import Dispatch

public class DeltaShrub<Key>: Delta /* TODO:❗️, Shrubbery */ where Key: Hashable {
    
    public typealias Drop = Shrub<Key>
    public typealias Fork = Drop.Fork
    public typealias Subject = PassthroughSubject<Result<Drop, Error>, Never>
    
    private var drop: Drop
    private let queue: DispatchQueue // TODO: a more generic Scheduler
    private let queueKey: DispatchSpecificKey<Void> // TODO: get rid of this
    private var subscriptions: Tree<Fork, Subject>
    private var transaction: [(route: [Fork], value: Any)] = []
    private var didEnterTransaction = false

    public init(
        drop: Drop = nil,
        subscriptions: Tree<Fork, Subject> = .init()
    ) {
        self.drop = drop
        self.queue = .init(
            label: "\(DeltaShrub<Key>.self).q_\(#file)_\(#line)",
            qos: .userInteractive
        )
        self.queueKey = queue.setSpecificKey()
        self.subscriptions = subscriptions
    }
}

extension DeltaShrub {

    public convenience init(_ unwrapped: Any) {
        self.init(drop: Drop(unwrapped), subscriptions: .init())
    }
}

extension DeltaShrub {
    
    public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {
        queue.sync(with: queueKey){
            Just(Result{ try drop.get(route) }).merge(
                with: subscriptions[value: route, inserting: Subject()].map{ o in
                    Result{ try o.get().as(A.self) }
                }
            )
            .eraseToAnyPublisher()
        }
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
        try queue.sync(with: queueKey){ try drop.get(route) }
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
        try queue.sync(with: queueKey){
            guard !didEnterTransaction else {
                transaction.append((Array(route), value))
                return
            }
            try drop.set(route, to: value)
            for route in route.lineage.reversed() {
                subscriptions[route]?.value?.send(Result{ try drop.get(route) })
            }
            subscriptions[route]?.traverse{ subroute, subject in
                subject?.send(Result{ try drop.get(route + subroute) })
            }
        }
    }
}

extension DeltaShrub {

    public var isInTransaction: Bool {
        queue.sync(with: queueKey){ didEnterTransaction }
    }

    public func beginTransaction() {
        queue.sync(with: queueKey){ didEnterTransaction = true }
    }

    public func endTransaction() throws {
        try queue.sync(with: queueKey) {
            var diff: Drop = .init()
            for (route, value) in transaction {
                try diff.set(route, to: value)
            }
            drop.merge(diff)
            var routes: [[Fork]: Subject] = [:]
            for (route, _) in transaction {
                for route in route.lineage.reversed() {
                    routes[Array(route)] = subscriptions[route]?.value
                }
                subscriptions[route]?.traverse{ subroute, subject in
                    routes[route + subroute] = subject
                }
            }
            for (route, subject) in routes.sorted(by: { a, b in a.key.count < b.key.count }) {
                subject.send(Result{ try drop.get(route) })
            }
            didEnterTransaction = false
        }
    }

    public func cancelTransaction() {
        queue.sync(with: queueKey) {
            transaction = []
            didEnterTransaction = false
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
        queue.sync(with: queueKey){
            do {
                try set(route, to: value.get())
            } catch {
                delete(route, because: error)
            }
        }
    }
}

extension DeltaShrub {
    
    public func delete(_ route: Fork..., because error: Error? = nil) {
        delete(route, because: error)
    }
    
    public func delete<Route>(_ route: Route, because error: Error? = nil)
    where
        Route: Collection,
        Route.Element == Fork
    {
        queue.sync(with: queueKey){
            drop.delete(route) // TODO:❗️store error for new subscribers (is using current value subject worth it?)
            let error: Result<Drop, Error> = .failure(error ?? "Route '\(route)' has been deleted".error())
            for route in route.lineage.reversed() {
                subscriptions[route]?.value?.send(error)
            }
            subscriptions[route]?.traverse{ subroute, subject in
                subject?.send(error)
            }
        }
    }
}

extension DeltaShrub: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        "Delta" + drop.debugDescription
    }
}

private extension Collection {

    var lineage: AnySequence<SubSequence> {
        AnySequence(sequence(first: dropLast()){ $0.dropLast().ifNotEmpty })
    }
}
