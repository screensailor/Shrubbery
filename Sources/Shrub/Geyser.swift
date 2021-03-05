public protocol Geyser: Spring where Key: RangeReplaceableCollection {
    
    func sources(of: Key) -> Stream<Shrub<Key, ()>>
}
