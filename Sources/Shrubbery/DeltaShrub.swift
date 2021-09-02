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
        set([], to: unwrapped)
    }

    public func set<A>(_ route: Fork..., to value: A) {
        set(route, to: value)
    }

    public func set<A, Route>(_ route: Route, to value: A)
    where
        Route: Collection,
        Route.Element == Fork
    {
        if let value = value as? Result<Any?, Error> { // TODO:❗️ think deeper
            switch value {
            case let .success(value): return set(route, to: value)
            case let .failure(error): return delete(route, because: error)
            }
        }
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
        nil
    }

    public func apply(_ batch: Batch) {
        sync {
            var routes: [[Fork]: Subject] = [:]
            batch.routes.traverse { route, isNewValue in
                guard isNewValue == true else { return }
                if let value = batch[route, as: Any?.self] {
                    shrub[route] = value
                } else {
                    shrub.delete(route)
                }
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

    public struct Batch {
        
        public typealias IsNewValue = Bool

        public private(set) var routes: Tree<Fork, IsNewValue>
        public private(set) var shrub: Shrub<Key>
        
        public func edits() -> [Route: Any?] {
            var o: [Route: Any?] = [:]
            routes.traverse { route, isNewValue in
                guard isNewValue == true else { return }
                o[route] = shrub[route, as: Any.self]
            }
            return o
        }
    }
}

extension DeltaShrub.Batch: Shrubbery {
    
    public var unwrapped: Any? {
        shrub.unwrapped
    }
    
    public init(_ unwrapped: Any?) {
        self.init(Shrub(unwrapped))
    }
    
    public init(_ shrub: Shrub<Key>) {
        self.shrub = shrub
        routes = .init()
    }
    
    public func get(_ route: Route) throws -> Self {
        try Self(shrub.get(route))
    }
    
    public mutating func set(_ route: Route, to value: Any?) {
        if let sentinel = value as? Sentinel, sentinel == .deletion {
            delete(route)
        } else {
            shrub.set(route, to: value)
            if (0..<route.count).allSatisfy({ routes[route.dropFirst($0)] == nil }) {
                routes[route] = .init(value: true, branches: [:])
            }
        }
    }
    
    public mutating func delete(_ route: Route) {
        shrub.delete(route)
        if (0..<route.count).allSatisfy({ routes[route.dropFirst($0)] == nil }) {
            routes[route] = .init(value: true, branches: [:])
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
