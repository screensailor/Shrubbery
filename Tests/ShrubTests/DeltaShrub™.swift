class DeltaShrub™: Hopes {
    
    private var bag: Set<AnyCancellable> = []

    func test_multicast() throws {
        
        var result = (0..<3).map{ Result<Int, Error>.failure("😱 \($0)") }
        
        var delta = DeltaJSON()
        
        delta.sync{ $0[1, "two", 3] = 4 }

        for i in result.indices {
            delta.flow(of: 1, "two", 3).sink{ result[i] = $0 }.store(in: &bag)
        }
        
        hope.for(0.01)

        hope(try result.map{ try $0.get() }) == Array(repeating: 4, count: result.count)
        
        delta.sync{ $0[1, "two", 3] = 5 }
        
        hope(try result.map{ try $0.get() }) == Array(repeating: 5, count: result.count)

        delta.sync{ $0[1, "two", 3] = 6 }
        
        hope(try result.map{ try $0.get() }) == Array(repeating: 6, count: result.count)

        hope.true(Thread.isMainThread)
        delta = DeltaJSON()
    }

    func test_selectiveness() throws {
        
        var count1 = 0
        var count2 = 0
        
        var r1: Result<Int, Error> = .failure("😱") { didSet { count1 += 1 } }
        var r2: Result<Int, Error> = .failure("😱") { didSet { count2 += 1 } }

        let delta = DeltaJSON()
        
        delta.sync{
            $0[1, "two", 3] = [
                "1": 4,
                "2": 4
            ]
        }

        delta.flow(of: 1, "two", 3, "1").sink{ r1 = $0 }.store(in: &bag)
        delta.flow(of: 1, "two", 3, "2").sink{ r2 = $0 }.store(in: &bag)
        
        hope.for(0.01)

        hope(r1) == 4
        hope(r2) == 4
        
        hope(count1) == 1
        hope(count2) == 1

        delta.sync{ $0[1, "two", 3, "2"] = 5 }
        
        hope(r1) == 4
        hope(r2) == 5
        
        hope(count1) == 1
        hope(count2) == 2
        
        delta.sync{
            $0[1, "two", 3] = [
                "1": 4,
                "2": 4
            ]
        }

        hope(r1) == 4
        hope(r2) == 4
        
        hope(count1) == 2
        hope(count2) == 3

    }
}

