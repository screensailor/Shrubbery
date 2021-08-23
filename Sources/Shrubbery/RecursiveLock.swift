import Foundation

typealias Lock = NSRecursiveLock

extension NSRecursiveLock {
    
    @inlinable public func sync<A>(_ work: () throws -> A) rethrows -> A {
        lock()
        defer{ unlock() }
        return try work()
    }
}
