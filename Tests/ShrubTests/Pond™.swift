class Pond™: Hopes {
    
    private var bag: Set<AnyCancellable> = []
    
    @Published var a: JSON = nil
    
    func test_Published() throws {
        
        var result: Result<Int, Error> = .failure("😱")

        $a["one", 2, "three"].sink{ result = $0 }.store(in: &bag)

        a["one", 2, "three"] = 4

        hope(result) == 4
    }
    
    func test_CurrentValueSubject() throws {

        let a: CurrentValueSubject<JSON, Never> = nil
        
        var result: Result<Int, Error> = .failure("😱")
        
        a["one", 2, "three"].sink{ result = $0 }.store(in: &bag)
        
        a.value["one", 2, "three"] = 4
        
        hope(result) == 4
    }
}
