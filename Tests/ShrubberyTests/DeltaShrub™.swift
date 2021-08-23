class DeltaShrub™: Hopes {
    
    private var bag: Set<AnyCancellable> = []

    func test_multicast() throws {
        
        var result = (0..<3).map{ Result<Int, Error>.failure("😱 \($0)") }
        
        var delta = DeltaJSON()
        
        delta.set(1, "two", 3, to: 4)
        
        hope(try delta.get(1, "two", 3)) == 4

        for i in result.indices {
            delta.flow(1, "two", 3).sink{ result[i] = $0 }.store(in: &bag)
        }

        hope(try result.map{ try $0.get() }) == Array(repeating: 4, count: result.count)

        delta.set(1, "two", 3, to: 5)

        hope(try result.map{ try $0.get() }) == Array(repeating: 5, count: result.count)

        delta.set(1, "two", 3, to: 6)

        hope(try result.map{ try $0.get() }) == Array(repeating: 6, count: result.count)

        hope.true(Thread.isMainThread)
        delta = DeltaJSON()
    }

    func test_counts() throws {
        
        var count = (a: 0, b: 0)
        
        var a: Result<Int, Error> = .failure("😱") { didSet { count.a += 1 } }
        var b: Result<Int, Error> = .failure("😱") { didSet { count.b += 1 } }

        let delta = DeltaJSON()
        
        delta.set(1, "two", 3, to: ["a": 4, "b": 4])

        delta.flow(1, "two", 3, "a").sink{ a = $0 }.store(in: &bag)
        delta.flow(1, "two", 3, "b").sink{ b = $0 }.store(in: &bag)

        hope(a) == 4
        hope(b) == 4
        
        hope(count.a) == 1
        hope(count.b) == 1

        delta.set(1, "two", 3, "b", to: 5)

        hope(a) == 4
        hope(b) == 5
        
        hope(count.a) == 1
        hope(count.b) == 2

        delta.set(1, "two", 3, to: ["a": 4, "b": 4])

        hope(a) == 4
        hope(b) == 4
        
        hope(count.a) == 1
        hope(count.b) == 3

        delta.set(1, to: Result<Int, Error>.failure("👌".error()))

        hope.throws(try a.get())
        hope.throws(try b.get())
        
        hope(count.a) == 2
        hope(count.b) == 4
    }

    func test_more_counts() throws {
        
        var count = (a: 0, b: 0)
        
        var a: Result<Int, Error> = .failure("😱") { didSet { count.a += 1 } }
        var b: Result<Int, Error> = .failure("😱") { didSet { count.b += 1 } }

        let delta = DeltaJSON()
        
        delta.set(1, "two", 3, to: ["a": 0, "b": 0])

        delta.flow(1, "two", 3, "a").sink{ a = $0 }.store(in: &bag)
        delta.flow(1, "two", 3, "b").sink{ b = $0 }.store(in: &bag)

        hope(a) == 0
        hope(b) == 0
        hope(count.a) == 1
        hope(count.b) == 1

        delta.set(1, "two", 3, "a", to: 1)
        hope(a) == 1
        hope(b) == 0
        hope(count.a) == 2
        hope(count.b) == 1

        delta.set(1, "two", 3, "a", to: 2)
        hope(a) == 2
        hope(b) == 0
        hope(count.a) == 3
        hope(count.b) == 1

        delta.set(1, "two", 3, "a", to: 3)
        hope(a) == 3
        hope(b) == 0
        hope(count.a) == 4
        hope(count.b) == 1

        delta.set(1, "two", 3, "b", to: 3)
        hope(a) == 3
        hope(b) == 3
        hope(count.a) == 4
        hope(count.b) == 2
    }
    
    func test_counts_with_un_Equatable() throws {
        
        struct UnEq {
            let x: Int
        }
        
        var count = 0
        
        var a: Result<UnEq, Error> = .failure("😱") { didSet { count += 1 } }

        let delta = DeltaJSON()
        
        delta.set(1, "two", 3, to: ["four": UnEq(x: 4)])

        delta.flow(1, "two", 3, "four").sink{ a = $0 }.store(in: &bag)
        
        delta.set(1, "two", 3, to: ["four": UnEq(x: 4)])

        hope(try a.get().x) == 4
        
        hope(count) == 2
    }

    func test_transaction() throws {

        var count = (a: 0, b: 0)

        var a: Result<Int, Error> = .failure("😱") { didSet { count.a += 1 } }
        var b: Result<Int, Error> = .failure("😱") { didSet { count.b += 1 } }

        let delta = DeltaJSON()

        delta.set(1, "two", 3, to: ["a": 0, "b": 0])

        delta.flow(1, "two", 3, "a").sink{ a = $0 }.store(in: &bag)
        delta.flow(1, "two", 3, "b").sink{ b = $0 }.store(in: &bag)

        var transaction = delta.transaction()

        hope(a) == 0
        hope(b) == 0
        hope(count.a) == 1
        hope(count.b) == 1

        transaction.set(1, "two", 3, "a", to: 1)
        transaction.set(1, "two", 3, "a", to: 2)
        transaction.set(1, "two", 3, "a", to: 3)
        transaction.set(1, "two", 3, "b", to: 3)

        hope(a) == 0
        hope(b) == 0
        hope(count.a) == 1
        hope(count.b) == 1

        delta.apply(transaction)

        hope(a) == 3
        hope(b) == 3
        hope(count.a) == 2
        hope(count.b) == 2

        transaction = delta.transaction()

        transaction.delete(1, "two", 3, "a")

        delta.apply(transaction)

        hope.throws(try a.get())
        hope(b) == 3
        hope(count.a) == 3
        hope(count.b) == 2
        hope.throws(try delta.shrub.get(1, "two", 3, "a") as Any)
        hope(try? delta.shrub.get(1, "two", 3, "b") as Int) == 3
    }

    func test_update_down() throws {
        
        let json: DeltaJSON = .init()
        
        var result: Result<Int, Error> = .failure("😱".error())
        
        json.flow("a", "b", "c").sink{ result = $0 }.store(in: &bag)
        hope.throws(try result.get())
        
        json.set("a", "b", "c", to: 1)
        hope(result) == 1
        
        json.delete("a", "b")
        hope.throws(try result.get())

        json.set("a", to: ["b": ["c": 2]])
        hope(result) == 2
    }
    
    func test_update_up() throws {
        
        let json: DeltaJSON = .init()
        
        var result_a: Result<Any?, Error> = .failure("😱".error())
        var result_b: Result<Any?, Error> = .failure("😱".error())

        json.flow("a").sink{ result_a = $0 }.store(in: &bag)
        json.flow("a", "b").sink{ result_b = $0 }.store(in: &bag)
        hope.throws(try result_a.get())
        
        json.set("a", "b", "c", to: 1)
        json.set("a", "B", "C", to: 2)
        hope(try result_a.get()) == ["b": ["c": 1], "B": ["C": 2]]
        hope(try result_b.get()) == ["c": 1]

        json.delete("a", "b")
        hope(try result_a.get()) == ["B": ["C": 2]]
        hope.throws(try result_b.get())

        json.set("a", to: ["b": ["c": 2]])
        hope(try result_a.get()) ==  ["b": ["c": 2]]
        hope(try result_b.get()) ==  ["c": 2]
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
            json1.flow(route, as: Int.self).sink{ result in
                try? json2.set(route, to: result.get())
            }.store(in: &bag)
        }
        
        for (i, route) in routes.enumerated() {
            json1.set(route, to: i)
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
            json1.flow(route, as: Int.self).sink{ result in
                try? json2.set(route, to: result.get())
            }.store(in: &bag)
        }
        
        let q = (1...4).map{ i in
            DispatchQueue(label: "q[\(i)]", attributes: .concurrent)
        }
        
        let g = DispatchGroup()
        
        for (i, route) in routes.enumerated() {
            g.enter()
            q[i % q.count].asyncAfter(deadline: .now() + .random(in: 0...0.01)) {
                json1.set(route, to: i)
                g.leave()
            }
        }
        
        hope(g.wait(timeout: .now() + 1)) == .success

        hope(json2.debugDescription) == json1.debugDescription
    }
    
    func test_performance() throws {
        
        measure {
            _ = try? test_thousand_subscriptions_and_concurrent_updates()
        }
    }
}
