extension RangeReplaceableCollection {
    
    
    public static func * <Count>(lhs: Self, rhs: Count) -> Self
    where Count: BinaryInteger
    {
        let count = Swift.max(0, Int(rhs))
        var o = Self()
        o.reserveCapacity(lhs.count * count)
        for _ in 0 ..< count {
            o.append(contentsOf: lhs)
        }
        return o
    }
}
