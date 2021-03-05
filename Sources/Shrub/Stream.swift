@_exported import Combine

public typealias Stream<A> = AnyPublisher<Result<A, Error>, Never>

extension Publisher {
    
    public func stream() -> Stream<Output> {
        self
            .map{ .success($0) }
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output: Wave, Failure == Never {

    public func get() -> AnyPublisher<Output.Value, Error> {
        self
            .tryMap{ try $0.get() }
            .eraseToAnyPublisher()
    }
    
    public func map<A>(_ ƒ: @escaping (Output.Value) throws -> A) -> Stream<A> {
        self
            .map{ x in Result{ try ƒ(x.get()) } }
            .eraseToAnyPublisher()
    }
}

