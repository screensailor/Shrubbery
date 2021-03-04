public struct Pond<G, Value>: Spring
where G: Geyser
{
    public let geyser: G
    
    public private(set) var data: Shrub<G.Key, Value> = nil
    public private(set) var sources: [G.Key: Int] = [:]
    
    public func stream<A>(of: G.Key, as: A.Type) -> Stream<A> {
        fatalError()
    }
}

