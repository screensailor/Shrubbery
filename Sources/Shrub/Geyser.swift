public protocol Geyser: Spring {
    
    func source(of: Key) -> Future<Key, Error>
}
