public typealias CodingIndex = EitherType<Int, String>

extension CodingIndex: CodingKey {
    
    @inlinable public var stringValue: String { description }
    @inlinable public init?(stringValue: String) { self.init(stringValue) }
    
    @inlinable public var intValue: Int? { a }
    @inlinable public init?(intValue: Int) { self.init(intValue) }
}

extension CodingIndex: CustomDebugStringConvertible {
    @inlinable public var debugDescription: String { description }
}

extension CodingIndex: ExpressibleByIntegerLiteral { // TODO: find the way to express where A|B == Int
    @inlinable public init(integerLiteral value: Int) { self.init(value) }
}

extension CodingIndex: ExpressibleByStringLiteral { // TODO: find the way to express where A|B == String
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
        lazy.map(\.description).joined(separator: separator)
    }
}
