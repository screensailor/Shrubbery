import Foundation

/// Serial queue with `sync` and `async` methods that execute work immediately if the process is already on this queue.
public final class RecursiveQueue {

    public let id: UInt
    public let label: String

    @inlinable public var isCurrent: Bool { DispatchQueue.getSpecific(key: k) != nil }

    public let k: DispatchSpecificKey<Void>
    public let q: DispatchQueue

    private static var count: UInt = 0
    private static let lock = NSRecursiveLock()

    public init(label: String? = nil, qos: DispatchQoS = .userInitiated) {
        RecursiveQueue.lock.lock()
        defer{ RecursiveQueue.lock.unlock() }
        RecursiveQueue.count += 1
        self.id = RecursiveQueue.count
        self.label = label ?? "uk.sky.AppGarden.q#\(RecursiveQueue.count)"
        self.k = DispatchSpecificKey<Void>()
        self.q = DispatchQueue(label: self.label, qos: qos)
        q.setSpecific(key: k, value: ())
    }

    /// Recursive sync
    @inlinable public func sync<T>(execute work: () throws -> T) rethrows -> T {
        isCurrent
            ? try work()
            : try q.sync(execute: work)
    }

    /// Async unless already on this queue
    @inlinable public func async(group: DispatchGroup? = nil, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping () -> Void) {
        isCurrent
            ? work()
            : q.async(group: group, qos: qos, flags: flags, execute: work)
    }
}
