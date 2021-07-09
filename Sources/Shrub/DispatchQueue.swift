import Dispatch

extension DispatchQueue {
    
    func setSpecificKey() -> DispatchSpecificKey<Void> {
        let o = DispatchSpecificKey<Void>()
        setSpecific(key: o, value: ())
        return o
    }
    
    func sync<T>(_ key: DispatchSpecificKey<Void>, execute work: () throws -> T) rethrows -> T {
        DispatchQueue.getSpecific(key: key) == nil
            ? try sync(execute: work)
            : try work()
    }
}
