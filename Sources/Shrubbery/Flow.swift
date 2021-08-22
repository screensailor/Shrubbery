public typealias Flow<A> = AnyPublisher<Result<A, Error>, Never>

public typealias AnyFlow = Flow<Any?>

extension Error {
    
    public func flow<A>(of: A.Type = A.self) -> Just<Result<A, Error>> {
        Just(Result<A, Error>.failure(self))
    }
}

extension Publisher where
    Output: Droplet,
    Output.Value: Equatable,
    Failure == Never
{
    public func removeDuplicates() -> Publishers.RemoveDuplicates<Self> {
        removeDuplicates { a, b in
            do { return try a.get() == b.get() }
            catch { return false }
        }
    }
}
