public class Pond<G, Value>: Spring
where
    G: Geyser,
    G.Key: RangeReplaceableCollection,
    G.Key.Element: Hashable
{
    public typealias Key = G.Key
    public typealias Index = G.Key.Element
    public typealias Subject = Publishers.Share<AnyPublisher<Result<Key, Error>, Never>>
    
    public let geyser: G
    
    public private(set) var data: Shrub<Index, Value> = nil
    
    private var bag: Set<AnyCancellable> = []
    
    public init(geyser: G) {
        self.geyser = geyser
    }
    
    public func stream<A>(of key: Key, as: A.Type) -> Stream<A> {
//        geyser
//            .source(of: key)
//            .flatMap{ [weak self] (result: Result<Key, Error>) -> Stream<A> in
//                guard let self = self else {
//                    return Just(.failure("\(Self.self) is no more".error())).eraseToAnyPublisher()
//                }
//                switch result {
//                case let .success(key): return self.geyser.stream(of: key, as: A.self)
//                case let .failure(error): return Just(.failure(error)).eraseToAnyPublisher()
//                }
//            }
//            .sink{ result in
//
//            }
//            .store(in: &bag)
        
        fatalError()
    }
}

