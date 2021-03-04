@_exported import Combine

public typealias Stream<A> = AnyPublisher<Result<A, Error>, Never>

extension Publisher {
    
    public func stream() -> Stream<Output> {
        return self
            .result()
            .map{ $0.mapError{ $0 } }
            .eraseToAnyPublisher()
    }
    
    public func result() -> AnyPublisher<Result<Output, Failure>, Never> {
        return self
            .map{ .success($0) }
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}
