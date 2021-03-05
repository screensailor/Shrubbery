public protocol Signal {
    
    associatedtype Value
    
    static func value(_: Value) -> Self
    static func error<E: Error>(_: E) -> Self
    
    var isError: Bool { get }
    
    func get() throws -> Value
}

extension Result: Signal where Failure == Error {
    
    public static func value(_ value: Success) -> Self { .success(value) }
    public static func error<E: Error>(_ error: E) -> Self { .failure(error) }
    
    public var isError: Bool { if case .failure = self { return true } else { return false } }
}

public protocol ResultProtocol {
    
    associatedtype Success
    associatedtype Failure: Error
    
    static func success(_: Success) -> Self
    static func failure(_: Failure) -> Self
    
    func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Result<NewSuccess, Failure>
    func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> Result<Success, NewFailure> where NewFailure : Error
    func flatMap<NewSuccess>(_ transform: (Success) -> Result<NewSuccess, Failure>) -> Result<NewSuccess, Failure>
    func flatMapError<NewFailure>(_ transform: (Failure) -> Result<Success, NewFailure>) -> Result<Success, NewFailure> where NewFailure : Error
    func get() throws -> Success
}

extension Result: ResultProtocol {}
