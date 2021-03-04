public struct Pond<G, Value>: Spring
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
    
    public func stream<A>(of key: Key, as: A.Type) -> Stream<A> {
        
        let x = geyser
            .source(of: key)
            
        
            
        let y = x.map{ $0 }
        
        fatalError()
    }
}

