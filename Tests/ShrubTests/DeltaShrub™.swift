class DeltaShrub™: Hopes {
    
    private var bag: Set<AnyCancellable> = []

    func test() throws {
        
        var result: Result<Int, Error> = .failure("😱")
        
        let loch = DeltaJSON()

        let route: JSONRoute = [1, "two", 3]
        
        loch.store[route] = 4

        loch.flow(of: route).sink{ result = $0 ¶ "✅ 1" }.store(in: &bag)
        loch.flow(of: route).sink{ result = $0 ¶ "✅ 2" }.store(in: &bag)
        loch.flow(of: route).sink{ result = $0 ¶ "✅ 3" }.store(in: &bag)
        
        hope(result) == 4
        
        loch.store[route] = 5
        
        hope(result) == 5
        
        loch.store[route] = 6
        
        hope(result) == 6
    }
}
