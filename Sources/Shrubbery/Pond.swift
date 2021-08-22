import Dispatch

public class Pond<Source>: Delta where Source: Geyser {

    public typealias Fork = Source.Fork
    public typealias Route = Source.Route
    public typealias Basin = DeltaShrub<Source.Key>
    public typealias Subject = CurrentValueSubject<Bool, Never>
    
    public struct Gush {
        public let cancel: (Int) -> ()
        public let didSink: Subject
        public let cancellable: AnyCancellable
    }

    public let geyser: Source
    
    public private(set) var basin: Basin
    public private(set) var subscriptions: Tree<Fork, Gush>

    public init(
        geyser: Source,
        basin: Basin = .init(),
        subscriptions: Tree<Fork, Gush> = .init()
    ) {
        self.geyser = geyser
        self.basin = basin
        self.subscriptions = subscriptions
    }
    
    public func flow(of route: Route) -> AnyFlow {
        do {
            let source = try geyser.source(of: route)
            return flow(of: route, from: source)
        } catch {
            return error.flow()
        }
    }

    private func flow(of route: Route, from source: Route) -> AnyFlow {

        let o: (didSink: Subject, cancel: (Int) -> ()) = basin.sync {

            if let subscription = subscriptions[value: source] {
                return (subscription.didSink, subscription.cancel)
            }
            else {
                var count = 0
                let cancel = { [weak self] (x: Int) in
                    count += x
                    if count < 1 {
                        assert(count == 0)
                        self?.subscriptions[value: source] = nil
                    }
                }
                let didSink = Subject(false)
                subscriptions[value: source] = Gush(
                    cancel: cancel,
                    didSink: didSink,
                    cancellable: geyser.gush(of: source).sink{ [weak didSink] result in
                        self.basin.set(source, to: result)
                        didSink?.send(true)
                    }
                )
                return (didSink, cancel)
            }
        }

        return o.didSink
            .first{ $0 }
            .flatMap{ _ in
                self.basin.flow(of: route)
            }
            .handleEvents(
                receiveSubscription: { _ in self.basin.sync{ o.cancel(+1) } },
                receiveCancel: { self.basin.sync{ o.cancel(-1) } }
            )
            .eraseToAnyPublisher()
    }
}

extension Pond.Gush: CustomStringConvertible {

    public var description: String {
        "Gush(didSink: \(didSink.value))"
    }
}
