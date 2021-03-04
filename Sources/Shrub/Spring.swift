public protocol Spring {
    
    associatedtype Index: Hashable
    
    func source(of: [Index]) -> Future<[Index], Error>
    func stream<A>(of: [Index], as: A.Type) -> Stream<A>
}

extension Spring {
    
    public func source(of: [Index]) -> Future<[Index], Error> {
        Future { $0(.success(of)) }
    }
    
    public func stream<A>(of: Index..., as: A.Type = A.self) -> Stream<A> {
        self.stream(of: of, as: A.self)
    }
}

