@_exported import Combine

public typealias Flow<A> = AnyPublisher<Result<A, Error>, Never>

public typealias AnyFlow = Flow<Any?>

extension AnyFlow {
    
    public func map<A>(_: A.Type = A.self) -> Flow<A> {
        map{ o in
            Result { () throws -> A in
                guard let r = try o.get() as? A else {
                    throw "\(type(of: o)) is not an \(A.self)"
                }
                return r
            }
        }
        .eraseToAnyPublisher()
    }
}

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
            .map{ x -> Flow<A> in
                do {
                    return try ƒ(x.get())
                } catch {
                    return Fail(error: error).flow()
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

extension Publisher
where
    Output: Droplet,
    Output.Value: Equatable,
    Failure == Never
{
    public func removeDuplicates() -> AnyPublisher<Output, Never> {
        self.removeDuplicates{ a, b in
            do {
                return try a.get() == b.get()
            }
            catch {
                return false
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Error {
    
    public func flow<A>(of: A.Type = A.self) -> Flow<A> {
        Just(Result<A, Error>.failure(self)).eraseToAnyPublisher()
    }
}
