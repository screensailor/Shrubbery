@_exported import Combine

@dynamicMemberLookup
public struct Drop<A, Key> {
    public let key: Key
    public let result: Result<A, Error>
}

extension Drop {
    public subscript<T>(dynamicMember keyPath: KeyPath<Result<A, Error>, T>) -> T {
        result[keyPath: keyPath]
    }
}

public typealias Flow<A> = AnyPublisher<Result<A, Error>, Never>

extension Publisher {
    
    public func flow() -> Flow<Output> {
        self
            .map{ .success($0) }
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}

extension Publisher
where
    Output: Droplet,
    Failure == Never
{
    
    public func unflow() -> AnyPublisher<Output.Value, Error> {
        self
            .tryMap{ try $0.get() }
            .eraseToAnyPublisher()
    }
    
    public func flowMap<A>(_ ƒ: @escaping (Output.Value) throws -> A) -> Flow<A> {
        self
            .map{ x in Result{ try ƒ(x.get()) } }
            .eraseToAnyPublisher()
    }
    
    public func flowFlatMap<A>(_ ƒ: @escaping (Output.Value) throws -> Flow<A>) -> Flow<A> {
        self
            .flatMap{ x -> Flow<A> in
                do {
                    return try ƒ(x.get())
                } catch {
                    return Fail(error: error).flow()
                }
            }
            .eraseToAnyPublisher()
    }
}
