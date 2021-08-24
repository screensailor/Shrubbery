public typealias Flow<A> = AnyPublisher<Result<A, Error>, Never>

public typealias AnyFlow = Flow<Any?>

extension Error {
    
    public func flow<A>(_: A.Type = A.self) -> Just<Result<A, Error>> {
        Just(Result<A, Error>.failure(self))
    }
}

extension Publisher where
    Output: Droplet,
    Output.Success: Equatable,
    Failure == Never
{
    public func removeDuplicates() -> Publishers.RemoveDuplicates<Self> {
        removeDuplicates { a, b in
            do { return try a.get() == b.get() }
            catch { return false }
        }
    }
}

extension Publisher where
    Output: Droplet,
    Failure == Never
{
    public func map<A>(_ ƒ: @escaping (Output.Success) throws -> A) -> Publishers.Map<Self, Result<A, Error>> {
        map { o in
            Result {
                try ƒ(o.get())
            }
        }
    }
    
    public func flatMap<A, E: Error>(_ ƒ: @escaping (Output.Success)   -> Result<A, E>) -> Publishers.Map<Self, Result<A, Error>> {
        map { o in
            Result {
                try ƒ(o.get()).get()
            }
        }
    }
    
    public func cast<A>(to: A.Type = A.self) -> Publishers.Map<Self, Result<A, Error>> {
        map{ o in
            Result {
                guard let r = try o.get() as? A else {
                    throw "\(o) of type \(type(of: o)) is not an \(A.self)" // TODO:❗️trace
                }
                return r
            }
        }
    }
    
    public func decode<A, D>(type: A.Type = A.self, decoder: D) -> Publishers.Map<Self, Result<A, Error>> where
        A: Decodable,
        D: TopLevelDecoder,
        D.Input == Any?
    {
        map{ o in
            Result {
                let o = try o.get()
                if let o = o as? A {
                    return o
                }
                return try decoder.decode(A.self, from: o)
            }
        }
    }
}
