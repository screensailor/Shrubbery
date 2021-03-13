import Dispatch

//public class DeltaSubject<Key, Value>: Delta where Key: Hashable {
//    
//    public typealias Subject = PassthroughSubject<DeltaSubject, Never>
//    public typealias Drop = Shrub<Key, Subject>
//    public typealias Fork = Drop.Index
//    public typealias Route = [Fork]
//    
//    private var drop: Drop
//    private var subscribers: Subscribers
//    private let queue: DispatchQueue
//
//    public init(
//        drop: Drop = nil,
//        subscribers: Subscribers = nil,
//        on queue: DispatchQueue = .init(
//            label: "\(DeltaShrub<Key, Value>.self).q",
//            qos: .userInteractive
//        )
//    ) {
//        self.drop = drop
//        self.subscribers = subscribers
//        self.queue = queue
//    }
//
//    public func flow<A>(of route: Route, as: A.Type = A.self) -> Flow<A> {
//        let subject: Subject = subscribers[route] ?? {
//            let o = Subject()
//            subscribers[route] = o
//            return o
//        }()
//        
//    }
//
//    public func get(_ path: [Drop.Index]) throws -> Drop {
//        fatalError()
//    }
//    
//    func set(_ value: Any?, at path: [Drop.Index]) throws {
//        fatalError()
//    }
//}
