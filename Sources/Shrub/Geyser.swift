public protocol Geyser: Spring {
    func source(of: Key) -> Stream<Key>
}
