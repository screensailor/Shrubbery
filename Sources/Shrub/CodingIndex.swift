public typealias CodingIndex = EitherType<Int, String>

extension CodingIndex {
    @inlinable public var int: Int? { a }
    @inlinable public var string: String? { b }
}

extension CodingIndex: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self.init(try container.decode(Int.self))
        } catch {
            self.init(try container.decode(String.self))
        }
    }
}

extension CodingIndex: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let .a(o): try container.encode(o)
        case let .b(o): try container.encode(o)
        }
    }
}

extension CodingIndex {
    public var debugDescription: String {
        switch value {
        case let .a(o): return String(describing: o)
        case let .b(o): return o
        }
    }
}

extension CodingIndex: CustomStringConvertible {
    @inlinable public var description: String { debugDescription }
}

extension CodingIndex: CodingKey {
    
    @inlinable public var stringValue: String { debugDescription }
    @inlinable public init?(stringValue: String) { self.init(stringValue) }
    
    @inlinable public var intValue: Int? { a }
    @inlinable public init?(intValue: Int) { self.init(intValue) }
}

extension CodingIndex: ExpressibleByIntegerLiteral {
    @inlinable public init(integerLiteral value: IntegerLiteralType) { self.init(value) }
}

extension CodingIndex: ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral value: String) { self.init(value) }
}

extension CodingIndex: ExpressibleByUnicodeScalarLiteral {
    @inlinable public init(unicodeScalarLiteral value: String) { self.init(value) }
}

extension CodingIndex: ExpressibleByExtendedGraphemeClusterLiteral {
    @inlinable public init(extendedGraphemeClusterLiteral value: String) { self.init(value) }
}

extension Collection where Element == CodingIndex {
    
    @inlinable public func joined(separator: String = ".") -> String {
        lazy.map(\.debugDescription).joined(separator: separator)
    }
}
