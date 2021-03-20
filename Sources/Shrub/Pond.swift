import Dispatch // TODO:❗️generalise to Schedulers

public class Pond<Source, Key>: Delta
where
    Key: Hashable,
    Source: Geyser,
    Source.Fork == EitherType<Int, Key>
{
    public typealias Fork = Source.Fork
    public typealias Route = Source.Route
    public typealias Basin = DeltaShrub<Key>
    public typealias Subject = CurrentValueSubject<Bool, Never>
    
    public struct Subscription {
        public let didSink: Subject
        public let cancellable: AnyCancellable
    }

    public let geyser: Source
    
    private var basin: Basin = .init()
    private var subscriptions: Tree<Fork, Subscription> = .init()
    
    private let queueKey: DispatchSpecificKey<Void>
    private let queue: DispatchQueue = .init(
        label: "\(Pond<Source, Key>.self).q",
        qos: .userInteractive
    )
    
    public init(geyser: Source) {
        self.queueKey = queue.setSpecificKey()
        self.geyser = geyser
    }
    
    public func flow<A>(of route: Route, as: A.Type) -> Flow<A> {
        
        let source: Route
        
        do {
            let endIndex = try geyser.source(of: route)
            guard endIndex >= route.startIndex else {
                return "Invalid end index of the source of route \(route)".error().flow()
            }
            source = route[..<endIndex].array
        }
        catch {
            return error.flow()
        }
        
        return flow(of: route, from: source, as: A.self)
    }
        
    private func flow<A>(of route: Route, from source: Route, as: A.Type) -> Flow<A> {
        queue.sync {
            guard let subscription = subscriptions[value: source] else {
                let didSink = Subject(false)
                subscriptions[value: source] = Subscription(
                    didSink: didSink,
                    cancellable: geyser.gush(of: source).receive(on: queue).sink{
                        [weak didSink] result in
                        self.basin.set(source, to: result)
                        didSink?.send(true)
                    }
                )
                return didSink.flow(of: route, in: basin, on: queue)
            }
            return subscription.didSink.flow(of: route, in: basin, on: queue)
        }
    }
}

private extension CurrentValueSubject where Output == Bool, Failure == Never {
    
    func flow<A, Key>(
        of route: DeltaShrub<Key>.Route,
        in basin: DeltaShrub<Key>,
        on queue: DispatchQueue
    ) -> Flow<A> {
        self.first(where: { $0 }).flatMap{ _ in
            basin.flow(of: route)
        }
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }
}
