public prefix func ^ <A, B>(a: A) -> EitherType<A, B> { .init(a) }
public prefix func ^ <A, B>(b: B) -> EitherType<A, B> { .init(b) }

public prefix func ^ <A, B, Path>(path: Path) -> [EitherType<A, B>]
where
    Path: Collection,
    Path.Element == A
{ path.map(EitherType.init) }

public prefix func ^ <A, B, Path>(path: Path) -> [EitherType<A, B>]
where
    Path: Collection,
    Path.Element == B
{ path.map(EitherType.init) }

public struct EitherType<A, B> {
    public private(set) var value: Value
}

extension EitherType {
    public enum Value { case a(A), b(B) }
}

extension EitherType {
    public init(_ a: A) { value = .a(a) }
    public init(_ b: B) { value = .b(b) }
}

extension EitherType {
    @inlinable public var a: A? { if case let .a(o) = value { return o } else { return nil } }
    @inlinable public var b: B? { if case let .b(o) = value { return o } else { return nil } }
}

extension EitherType {
    
    @inlinable public subscript(type: A.Type = A.self) -> A? { a }
    @inlinable public subscript(type: B.Type = B.self) -> B? { b }
    
    @inlinable public func cast<T>(to: T.Type = T.self) -> T? { a as? T ?? b as? T }
}

extension EitherType.Value: Equatable where A: Equatable, B: Equatable {}

extension EitherType: Equatable where A: Equatable, B: Equatable {
    
    @inlinable public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
    
    @inlinable public static func == (lhs: Self, rhs: EitherType<B, A>) -> Bool {
        switch (lhs.value, rhs.value)
        {
        case let (.a(l), .b(r)): return l == r
        case let (.b(l), .a(r)): return l == r
        default: return false
        }
    }
}

extension EitherType.Value: Hashable where A: Hashable, B: Hashable {
    @inlinable public func hash(into hasher: inout Hasher) {
        switch self {
        case let .a(o): hasher.combine(o)
        case let .b(o): hasher.combine(o)
        }
    }
}

extension EitherType: Hashable where A: Hashable, B: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension EitherType: CustomStringConvertible {
    public var description: String {
        switch value {
        case let .a(o): return String(describing: o)
        case let .b(o): return String(describing: o)
        }
    }
}

public struct EitherTypeDecodingError: Error {
    let error: (a: Error, b: Error)
}

extension EitherType: Decodable
where
    A: Decodable,
    B: Decodable
{
    public init(from decoder: Decoder) throws {
        do {
            try self.init(A(from: decoder))
        } catch let a {
            do {
                try self.init(B(from: decoder))
            } catch let b {
                throw EitherTypeDecodingError(error: (a, b))
            }
        }
    }
}

extension EitherType: Encodable
where
    A: Encodable,
    B: Encodable
{
    public func encode(to encoder: Encoder) throws {
        switch value {
        case let .a(o): try o.encode(to: encoder)
        case let .b(o): try o.encode(to: encoder)
        }
    }
}

extension EitherType {
    public var debugDescription: String {
        switch value {
        case let .a(o): return String(describing: o)
        case let .b(o): return String(describing: o)
        }
    }
}
