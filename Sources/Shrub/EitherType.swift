prefix operator ^ /// lift operator

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

extension EitherType: Identifiable where A: Hashable, B: Hashable {
    public var id: Self { return self }
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

extension EitherType: Comparable where A: Comparable, B: Comparable {
    public static func < (lhs: EitherType<A, B>, rhs: EitherType<A, B>) -> Bool {
        switch (lhs.value, rhs.value) {
        case (.a, .b): return true
        case (.b, .a): return false
        case let (.a(lhs), .a(rhs)): return lhs < rhs
        case let (.b(lhs), .b(rhs)): return lhs < rhs
        }
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

extension EitherType {
    
    public static func randomRoute(
        in a: [A],
        and b: [B],
        bias: Double = 0.5,
        length: ClosedRange<Int>
    ) -> [Self] {
        let lower = max(0, length.lowerBound)
        let upper = max(lower, length.upperBound)
        
        return (0 ..< Int.random(in: lower...upper)).compactMap{ _ -> Self? in
            Double.random(in: 0...1) < bias
                ? a.randomElement().map{ Self($0) }
                : b.randomElement().map{ Self($0) }
        }
    }

    public static func randomRoutes(
        count: Int,
        in a: [A],
        and b: [B],
        bias: Double = 0.5,
        length: ClosedRange<Int>
    ) -> [[Self]] {
        (0..<max(0, count)).map{ _ in
            randomRoute(in: a, and: b, bias: bias, length: length)
        }
    }
}

#if canImport(GameplayKit)
import GameplayKit

extension EitherType {
    
    public static func randomRoute(
        in a: [A],
        and b: [B],
        bias: Double = 0.5,
        length: ClosedRange<Int>,
        random: GKARC4RandomSource
    ) -> [Self] {
        let lower = max(0, length.lowerBound)
        let upper = max(lower, length.upperBound)
        let count = random.nextInt(upperBound: upper - lower + 1) + lower
        return (0 ..< count).compactMap{ _ -> Self? in
            Double(random.nextUniform()) < bias
                ? random.randomElement(in: a).map{ Self($0) }
                : random.randomElement(in: b).map{ Self($0) }
        }
    }

    public static func randomRoutes(
        count: Int,
        in a: [A],
        and b: [B],
        bias: Double = 0.5,
        length: ClosedRange<Int>,
        seed: Int
    ) -> [[Self]] {
        let random = GKARC4RandomSource(seed: "seed \(seed)".data(using: .utf8)!)
        return (0..<max(0, count)).map{ _ in
            randomRoute(in: a, and: b, bias: bias, length: length, random: random)
        }
    }
}

private extension GKARC4RandomSource {
    
    func randomElement<A>(in a: [A]) -> A? {
        guard !a.isEmpty else { return nil }
        return a[nextInt(upperBound: a.count)]
    }
}
#endif
