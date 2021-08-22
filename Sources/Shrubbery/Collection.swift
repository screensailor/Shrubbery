internal extension Collection {
    
    var ifNotEmpty: Self? { isEmpty ? nil : self }
    
    var array: [Element] { Array(self) }
}

extension Collection where Indices == Range<Int> {
    
    @inlinable public func cycle(to index: Int) throws -> Element {
        try self[index.cycled(over: indices)]
    }
}

extension SignedInteger {
    
    public func cycled(by offset: Self = 0, over range: Range<Self>) throws -> Self {
        guard !range.isEmpty else { throw "Range \(self) is empty" }
        let d = self % (range.upperBound - range.lowerBound)
        return d < 0 ? range.upperBound + d : range.lowerBound + d
    }
}
