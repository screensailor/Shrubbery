import Dispatch

public class Pond<Source>: Delta where Source: Geyser {

    public typealias Fork = Source.Fork
    public typealias Route = Source.Route
    public typealias Basin = DeltaShrub<Source.Key>
    public typealias Subject = CurrentValueSubject<Bool, Never>
    
    public struct Subscription {
        public let cancel: (Int) -> ()
        public let didSink: Subject
        public let cancellable: AnyCancellable
    }

    public let geyser: Source
    
    public private(set) var basin: Basin
    public private(set) var subscriptions: Tree<Fork, Subscription>
    
    private let q: DispatchQueue = .init(
        label: "\(Pond<Source>.self).q_\(#file)_\(#line)",
        qos: .userInteractive
    )
    
    public init(
        geyser: Source,
        basin: Basin = .init(),
        subscriptions: Tree<Fork, Subscription> = .init()
    ) {
        self.geyser = geyser
        self.basin = basin
        self.subscriptions = subscriptions
    }
    
    public func flow<A>(of route: Route, as: A.Type) -> Flow<A> {
        do {
            let source = try geyser.source(of: route)
            return flow(of: route, from: source, as: A.self)
        } catch {
            return error.flow()
        }
    }

    private func flow<A>(of route: Route, from source: Route, as: A.Type) -> Flow<A> {
        q.sync {
            if let subscription = subscriptions[value: source] {
                return subscription.didSink.flow(of: route, in: basin, cancel: subscription.cancel)
            }
            var count = 0
            let cancel = { [weak self] (x: Int) in
                guard let self = self else { return }
                self.q.sync {
                    count += x
                    if count < 1 {
                        assert(count == 0)
                        self.subscriptions[value: source] = nil
                    }
                }
            }
            let didSink = Subject(false)
            subscriptions[value: source] = Subscription(
                cancel: cancel,
                didSink: didSink,
                cancellable: geyser.gush(of: source).sink{ [weak didSink] result in
                    didSink?.send(true)
                    self.basin.set(source, to: result)
                }
            )
            return didSink.flow(of: route, in: basin, cancel: cancel)
        }
    }
}

private extension CurrentValueSubject where Output == Bool, Failure == Never {
    
    func flow<A, Key>(
        of route: DeltaShrub<Key>.Route,
        in basin: DeltaShrub<Key>,
        cancel: @escaping (Int) -> ()
    ) -> Flow<A> {
        first(where: { $0 })
            .flatMap{ _ in
                basin.flow(of: route)
            }
            .handleEvents(
                receiveSubscription: { _ in cancel(+1) },
                receiveCancel: { cancel(-1) }
            )
            .eraseToAnyPublisher()
    }
}
