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

import Dispatch
import CombineSchedulers

public typealias DeltaJSON = DeltaShrub<String, JSONFragment>

public class DeltaShrub<Key, Value>: Delta where Key: Hashable {
    
    public typealias Drop = Shrub<Key, Value>
    public typealias Fork = Drop.Index
    public typealias Route = [Fork]
    
    @Published private var drop: Drop = nil
    
    private lazy var routes = DefaultInsertingDictionary<Route, Flow<Drop>>(default: shared)
    
    private let scheduler: DispatchQueue

    public init(
        drop: Drop = nil,
        on scheduler: DispatchQueue = DispatchQueue(
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
        routes[route]
            .map{ o in Result{ try o.get().as(A.self) } }
            .merge(with: Just(Result{ try drop.get(route, as: A.self) } ))
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }

    private func shared(_ route: Route) -> Flow<Drop> {
        $drop.map{ o in Result{ try o.get(route, as: Drop.self) } }
            .dropFirst()
            .multicast(subject: PassthroughSubject())
            .autoconnect()
            .eraseToAnyPublisher()
    }
}
