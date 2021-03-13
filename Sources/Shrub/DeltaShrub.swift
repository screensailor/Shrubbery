import Peek
import Dispatch

public typealias DeltaJSON = DeltaShrub<String, JSONFragment>

public class DeltaShrub<Key, Value>: Delta where Key: Hashable, Key: Collection {
    
    public typealias Drop = Shrub<Key, Value>
    public typealias Fork = Drop.Index
    public typealias Route = [Fork]
    public typealias Subject = PassthroughSubject<Result<Drop, Error>, Never>
    
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
}

extension DeltaShrub {
    
    public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {
        Just(Result{ try drop.get(route) }).merge(
            with: subjects[value: route, inserting: Subject()].map{ o in Result{ try o.get().as(A.self) } }
        ).eraseToAnyPublisher()
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
        try drop.get(route, as: A.self)
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
        try drop.set(value, at: route)
        subjects[route]?.traverse { subroute, subject in
            subject?.send(Result{ try drop.get(route + subroute) })
        }
    }
}
