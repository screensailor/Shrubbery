public struct Pond<A, Value>: Spring
where A: Spring
{
    public typealias Index = A.Index
    
    public let spring: A
    
    public private(set) var data: Shrub<Index, Value> = nil
    public private(set) var sources: [[Index]: Int] = [:]
    
    public func stream<A>(of: [Index], as: A.Type) -> Stream<A> {
        fatalError()
    }
}

