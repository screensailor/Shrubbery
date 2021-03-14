import Dispatch // TODO:❗️generalise to Schedulers
/**
 * - unflow everything?, keep .flow() as just an operator?
 * - Datum<Key, Value, Context> instead of Result<Value, Error>
 * - events vs? streams - i.e. events as streams of () or of Event value?
 * - subscribing vs observing
 * - concurrent and serial dependencies - i.e. group vs sequence
 * - flat collections (path components) vs deep documents (values)
 * - decoder & encoder of ``Shrubbery`` (`as _: A.Type` tries a cast then decode where `A: Decodable`)
 */
public struct Datum<Key, Value, Context> where Key: Hashable {
    public let source: [EitherType<Int, Key>]
    public let result: Result<Shrub<Key, Value>, Error>
    public let context: Context
}

public protocol Encoded: Shrubbery where Key == String, Value: Codable {}
public typealias Coded = Shrub<String, Codable>

public typealias Flow<A> = AnyPublisher<Result<A, Error>, Never>

public protocol Delta {
    associatedtype Fork
    typealias Route = [Fork]
    func flow<A>(of: Route, as: A.Type) -> Flow<A>
}

public protocol Geyser: Delta {
    associatedtype Value
    func gush(of: Route) -> Flow<Value>
    func source(of: Route) throws -> Route.Index // TODO:❗️-> AnyPublisher<Route.Index, Error>
}

public enum GeyserError<Route>: Error {
    case badRoute(route: Route, message: String)
}

extension Geyser where Value: Shrubbery {
    
    public func flow<A>(of route: Route, as: A.Type) -> Flow<A> {
        gush(of: route).map{ o in Result{ try o.get().as(A.self) } }.eraseToAnyPublisher()
    }
}

public class Pond<Source, Key>: Delta
where
    Key: Hashable,
    Source: Geyser,
    Source.Fork == EitherType<Int, Key>
{
    public typealias Fork = Source.Fork
    public typealias Route = Source.Route
    public typealias Basin = DeltaShrub<Key, Source.Value>
    public typealias Subject = PassthroughSubject<(), Never>
    
    public let geyser: Source
    
    private var basin: Basin
    
    private let queue: DispatchQueue
    private var subscriptions: Tree<Fork, Subscription>
    
    public enum Subscription {
        case waiting(AnyCancellable, Subject)
        case ready(AnyCancellable)
    }
    
    public init(
        geyser: Source,
        basin: Basin = .init(),
        on queue: DispatchQueue = .init(
            label: "\(Pond<Source, Key>.self).q",
            qos: .userInteractive
        ),
        subscriptions: Tree<Fork, Subscription> = .init()
    ) {
        self.geyser = geyser
        self.basin = basin
        self.queue = queue
        self.subscriptions = subscriptions
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
        
        return queue.sync {
            switch subscriptions[value: source]
            {
            case let .waiting(_, subject)?:
                return subject.flatMap{ _ in
                    self.basin.flow(of: route)
                }
                .subscribe(on: queue)
                .eraseToAnyPublisher()
                
            case .ready?:
                return basin.flow(of: route)
                
            default:
                var didSink = false
                let subscription = geyser.gush(of: source).sink{ result in
                    self.basin.set(source, to: result)
                    if
                        !didSink,
                        case let .waiting(subscription, subject) = self.subscriptions[value: source]
                    {
                        self.subscriptions[value: source] = .ready(subscription)
                        subject.send()
                    }
                    didSink = true
                }
                if didSink {
                    subscriptions[value: source] = .ready(subscription)
                    return basin.flow(of: route)
                }
                else {
                    let subject = Subject()
                    subscriptions[value: source] = .waiting(subscription, subject)
                    return subject.flatMap{ _ in
                        self.basin.flow(of: route)
                    }
                    .subscribe(on: queue)
                    .eraseToAnyPublisher()
                }
            }
        }
    }
}

