public class KeySubject<Key, Value>: Hashable where Key: Hashable {
    
    public let key: Key
    public let subject: PassthroughSubject<Value, NotFound>
    
    public struct NotFound: Error { public let key: Key }
    
    public init(key: Key, subject: PassthroughSubject<Value, NotFound> = .init()) {
        self.key = key
        self.subject = subject
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.key == rhs.key && lhs.subject === rhs.subject
    }
}
