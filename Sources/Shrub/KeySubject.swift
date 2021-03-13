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
    
    public static func == (lhs: KeySubject<Key, Value>, rhs: KeySubject<Key, Value>) -> Bool {
        lhs.key == rhs.key
    }
}

extension Hashable {
    
    public func keySubject<Value>(for: Value.Type = Value.self) -> KeySubject<Self, Value> {
        .init(key: self)
    }
}
