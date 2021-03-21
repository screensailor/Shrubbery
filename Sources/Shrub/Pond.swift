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
        public let lifecycle: (Int) -> ()
        public let cancellable: AnyCancellable
    }

    public let geyser: Source
    
    private var basin: Basin = .init()
    private var subscriptions: Tree<Fork, Subscription> = .init()
    
    private let queue: DispatchQueue = .init(
        label: "\(Pond<Source, Key>.self).q",
        qos: .userInteractive
    )
    
    public init(geyser: Source) {
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
                var count = 0
                let lifecycle = { (x: Int) -> () in
                    count += x
                    if count < 1 { assert(count == 0)
                        self.subscriptions[value: source] = nil
                    }
                }
                let didSink = Subject(false)
                subscriptions[value: source] = Subscription(
                    didSink: didSink,
                    lifecycle: lifecycle,
                    cancellable: geyser.gush(of: source).receive(on: queue).sink{ [weak didSink] result in
                        self.basin.set(source, to: result)
                        didSink?.send(true)
                    }
                )
                return didSink.flow(of: route, in: basin, on: queue, lifecycle: lifecycle)
            }
            return subscription.didSink.flow(of: route, in: basin, on: queue, lifecycle: subscription.lifecycle)
        }
    }
}

private extension CurrentValueSubject where Output == Bool, Failure == Never {
    
    func flow<A, Key>(
        of route: DeltaShrub<Key>.Route,
        in basin: DeltaShrub<Key>,
        on queue: DispatchQueue,
        lifecycle: @escaping (Int) -> ()
    ) -> Flow<A> {
        self.first(where: { $0 }).flatMap{ _ in
            basin.flow(of: route)
        }
        .handleEvents(
            receiveSubscription: { _ in lifecycle(1) },
            receiveCancel: { lifecycle(-1) }
        )
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }
}
