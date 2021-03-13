import Dispatch

public class DeltaSubject<Key, Value>: Delta where Key: Hashable {
    
    public typealias Drop = Shrub<Key, Value> // TODO:❗️use generic Shrubbery instead
    public typealias Fork = Drop.Index
    public typealias Route = [Fork]
    public typealias Subscribers = Shrub<Key, PassthroughSubject<Result<Drop, Error>, Never>>
    
    private var drop: Drop
    private var subscribers: Subscribers = nil
    private let queue: DispatchQueue

    public init(
        drop: Drop = nil,
        subscribers: Subscribers = nil,
        on queue: DispatchQueue = .init(
            label: "\(DeltaShrub<Key, Value>.self).q",
            qos: .userInteractive
        )
    ) {
        self.drop = drop
        self.subscribers = subscribers
        self.queue = queue
    }

    public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {

        fatalError()
    }
}
