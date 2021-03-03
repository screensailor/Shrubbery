class Pond™: XCTestCase {
    
    private var bag: Set<AnyCancellable> = []
    
    @Published var a: JSON = nil
    
    func test_Published() throws {
        
        var result: Result<Int, Error> = .failure("😱".error())

        $a.stream(of: "one", 2, "three")
            .sink{ result = $0 }
            .store(in: &bag)

        a["one", 2, "three"] = 4

        try hope(result.get()) == 4
    }
    
    func test_CurrentShrubSubject() throws {

        let a = CurrentShrubSubject<JSON>(nil)
        
        var result: Result<Int, Error> = .failure("😱".error())
        
        a.stream(of: "one", 2, "three")
            .sink{ result = $0 }
            .store(in: &bag)
        
        a.value["one", 2, "three"] = 4
        
        try hope(result.get()) == 4
    }
}
