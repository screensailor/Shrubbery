public protocol Geyser: Spring {
    
    typealias Path = [Index]
    associatedtype Index: Hashable
    
    func path(for: Key) -> Path
    func sources(of: Key) -> Stream<Shrub<Key, ()>>
}
