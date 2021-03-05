public protocol Geyser: Spring {
    func sources(of: Key) -> Stream<Shrub<Key, Key>>
}
