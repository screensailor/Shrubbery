class DeltaShrub™: Hopes {
    
    private var bag: Set<AnyCancellable> = []

    func test_multicast() throws {
        
        var result = (0..<3).map{ Result<Int, Error>.failure("😱 \($0)") }
        
        var delta = DeltaJSON()
        
        try delta.set(1, "two", 3, to: 4)
        
        hope(try delta.get(1, "two", 3)) == 4

        for i in result.indices {
            delta.flow(of: 1, "two", 3).sink{ result[i] = $0 }.store(in: &bag)
        }
        
        hope.for(0.01)

        hope(try result.map{ try $0.get() }) == Array(repeating: 4, count: result.count)

        try delta.set(1, "two", 3, to: 5)

        hope(try result.map{ try $0.get() }) == Array(repeating: 5, count: result.count)

        try delta.set(1, "two", 3, to: 6)

        hope(try result.map{ try $0.get() }) == Array(repeating: 6, count: result.count)

        hope.true(Thread.isMainThread)
        delta = DeltaJSON()
    }

    func test_counts() throws {
        
        var count = (a: 0, b: 0)
        
        var a: Result<Int, Error> = .failure("😱") { didSet { count.a += 1 } }
        var b: Result<Int, Error> = .failure("😱") { didSet { count.b += 1 } }

        let delta = DeltaJSON()
        
        try delta.set(1, "two", 3, to: ["a": 4, "b": 4])

        delta.flow(of: 1, "two", 3, "a").sink{ a = $0 }.store(in: &bag)
        delta.flow(of: 1, "two", 3, "b").sink{ b = $0 }.store(in: &bag)
        
        hope.for(0.01)

        hope(a) == 4
        hope(b) == 4
        
        hope(count.a) == 1
        hope(count.b) == 1

        try delta.set(1, "two", 3, "b", to: 5)

        hope(a) == 4
        hope(b) == 5
        
        hope(count.a) == 1
        hope(count.b) == 2

        try delta.set(1, "two", 3, to: ["a": 4, "b": 4])

        hope(a) == 4
        hope(b) == 4
        
        hope(count.a) == 2
        hope(count.b) == 3

        delta.set(1, to: Result<Int, Error>.failure("👌".error()))

        hope.throws(try a.get())
        hope.throws(try b.get())
        
        hope(count.a) == 3
        hope(count.b) == 4
    }

    func test_more_counts() throws {
        
        var count = (a: 0, b: 0)
        
        var a: Result<Int, Error> = .failure("😱") { didSet { count.a += 1 } }
        var b: Result<Int, Error> = .failure("😱") { didSet { count.b += 1 } }

        let delta = DeltaJSON()
        
        try delta.set(1, "two", 3, to: ["a": 0, "b": 0])

        delta.flow(of: 1, "two", 3, "a").sink{ a = $0 }.store(in: &bag)
        delta.flow(of: 1, "two", 3, "b").sink{ b = $0 }.store(in: &bag)
        
        hope.for(0.01)
        hope(a) == 0
        hope(b) == 0
        hope(count.a) == 1
        hope(count.b) == 1

        try delta.set(1, "two", 3, "a", to: 1)
        hope.for(0.01)
        hope(a) == 1
        hope(b) == 0
        hope(count.a) == 2
        hope(count.b) == 1

        try delta.set(1, "two", 3, "a", to: 2)
        hope.for(0.01)
        hope(a) == 2
        hope(b) == 0
        hope(count.a) == 3
        hope(count.b) == 1

        try delta.set(1, "two", 3, "a", to: 3)
        hope.for(0.01)
        hope(a) == 3
        hope(b) == 0
        hope(count.a) == 4
        hope(count.b) == 1

        try delta.set(1, "two", 3, "b", to: 3)
        hope.for(0.01)
        hope(a) == 3
        hope(b) == 3
        hope(count.a) == 4
        hope(count.b) == 2
    }
    
    func test_thousand_subscriptions() throws {
        
        let routes = JSON.Fork.randomRoutes(
            count: 1000,
            in: Array(0...2),
            and: "abc".map(String.init),
            bias: 0.1,
            length: 5...7,
            seed: 502645 // Int.random(in: 1000...1_000_000).peek("✅")
        )
        
        let json1: DeltaJSON = .init()
        let json2: DeltaJSON = .init()
        
        for route in routes {
            json1.flow(of: route, as: Int.self).sink{ result in
                try? json2.set(route, to: result.get())
            }.store(in: &bag)
        }
        
        for (i, route) in routes.enumerated() {
            try json1.set(route, to: i)
        }

        hope(json2.debugDescription) == json1.debugDescription
        
    }
    
    func test_thousand_subscriptions_and_concurrent_updates() throws {
        
        let routes = JSON.Fork.randomRoutes(
            count: 1000,
            in: Array(0...2),
            and: "abc".map(String.init),
            bias: 0.1,
            length: 5...7,
            seed: 502645 // Int.random(in: 1000...1_000_000).peek("✅")
        )
        
        let json1: DeltaJSON = .init()
        let json2: DeltaJSON = .init()
        
        for route in routes {
            json1.flow(of: route, as: Int.self).sink{ result in
                try? json2.set(route, to: result.get())
            }.store(in: &bag)
        }
        
        let qs = (1...5).map{ i in
            DispatchQueue(label: "qs[\(i)]", attributes: .concurrent)
        }
        
        let g = DispatchGroup()
        
        for (i, route) in routes.enumerated() {
            g.enter()
            let q = qs[i % qs.count]
            q.asyncAfter(deadline: .now() + .random(in: 0...0.01)) {
                try? json1.set(route, to: i)
                g.leave()
            }
        }
        
        hope(g.wait(timeout: .now() + 5)) == .success

        hope(json2.debugDescription) == json1.debugDescription
        
        debugPrint(json2)
    }
}

