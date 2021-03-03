import Combine

public typealias Stream<A> = AnyPublisher<Result<A, Error>, Never>

public protocol Spring {
    
    associatedtype Index: Hashable
    
    func source(of: [Index]) -> Future<[Index], Error>
    func stream<A>(of: [Index], as: A.Type) -> Stream<A>
}

extension Spring {
    
    public func source(of: [Index]) -> Future<[Index], Error> {
        Future { $0(.success(of)) }
    }
}

public typealias CurrentShrubSubject<A: Shrubbery> = CurrentValueSubject<JSON, Never>

extension CurrentValueSubject: Spring
where
    Output: Shrubbery,
    Failure == Never
{
    public typealias Index = Output.Index
    
    public func stream<A>(of: [Index], as: A.Type) -> Stream<A> {
        self
            .map{ o in Result{ try o.get(of, as: A.self) } }
            .eraseToAnyPublisher()
    }
}

public struct Pond<A, Value>: Spring
where A: Spring
{
    public typealias Index = A.Index
    
    public let spring: A
    
    public private(set) var data: Shrub<Index, Value> = nil
    public private(set) var sources: [[Index]: Int] = [:]
    
    public func stream<A>(of: [Index], as: A.Type) -> Stream<A> {
        fatalError()
    }
}

