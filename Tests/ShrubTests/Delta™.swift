class Delta™: Hopes {
    
    private var bag: Set<AnyCancellable> = []
    
    @Published var json: JSON = nil
    
    func test_Published() throws {
        
        var result: Result<Int, Error> = .failure("😱")

        $json["one", 2, "three"].sink{ result = $0 }.store(in: &bag)

        json["one", 2, "three"] = 4

        hope(result) == 4
    }
    
    func test_CurrentValueSubject() throws {

        let json: CurrentValueSubject<JSON, Never> = .init(nil)
        
        var result: Result<Int, Error> = .failure("😱")
        
        json["one", 2, "three"].sink{ result = $0 }.store(in: &bag)
        
        json.value["one", 2, "three"] = 4
        
        hope(result) == 4
    }
    
    func test_flowFlatMap() throws {
        
        let json = CurrentValueSubject<JSON.Result, Never>(^0)
        
        var result: JSON.Result = .failure("😱")

        json.flowFlatMap{ o in Just(o).flow() }.sink{ result = $0 }.store(in: &bag)

        json.value = ^4.0
        hope(try result.get().cast()) == 4.0

        json.value = .failure("😱")

        json.value = ^5.0
        hope(try result.get().cast()) == 5.0
    }
}
