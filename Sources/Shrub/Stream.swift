@_exported import Combine

public typealias Stream<A> = AnyPublisher<Result<A, Error>, Never>

extension Publisher {
    
    public func stream() -> Stream<Output> {
        self
            .result()
            .map{ $0.mapError{ $0 } }
            .eraseToAnyPublisher()
    }
    
    public func result() -> AnyPublisher<Result<Output, Failure>, Never> {
        self
            .map{ .success($0) }
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output: Signal {
    
    public func get() -> AnyPublisher<Output.Value, Error> {
        self
            .tryMap{ try $0.get() }
            .eraseToAnyPublisher()
    }
    
    public func map<A>(_ ƒ: @escaping (Output.Value) throws -> A) -> AnyPublisher<Result<A, Error>, Failure> {
        self
            .map{ (o: Output) -> Result<A, Error> in
                do {
                    let x = try o.get()
                    let y = try ƒ(x)
                    return .success(y)
                }
                catch { return .failure(error) }
            }
            .eraseToAnyPublisher()
    }
}

