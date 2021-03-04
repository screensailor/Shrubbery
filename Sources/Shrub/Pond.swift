public struct Pond<S, Value>: Spring
where S: Spring
{
    public let spring: S
    
    public private(set) var data: Shrub<S.Key, Value> = nil
    public private(set) var sources: [S.Key: Int] = [:]
    
    public func stream<A>(of: S.Key, as: A.Type) -> Stream<A> {
        fatalError()
    }
}

