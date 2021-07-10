class Pond™: Hopes {
    
    private var bag: Set<AnyCancellable> = []
    
    func test_subscription_lifecycle() throws {
        
        let db = Database(depth: 1)
        let pond = Pond(geyser: db)
        
        hope(db.count.subscriptions) == 0
        
        var a: Result<Int, Error> = .failure("😱")
        
        pond.flow(of: "a", 2, "c").sink{ a = $0 }.store(in: &bag)
        
        hope(db.count.subscriptions) == 1
        hope.throws(try a.get())
        
        try db.store.set("a", 2, "c", to: 2)
        hope(db.count.subscriptions) == 1
        hope(a) == 2
        
        pond.flow(of: "a", 2, "c").sink{ a = $0 }.store(in: &bag)
        hope(db.count.subscriptions) == 1
        
        pond.flow(of: "a", 2, "d").sink{ a = $0 }.store(in: &bag)
        hope(db.count.subscriptions) == 1
        
        pond.flow(of: "b", 2, "c").sink{ a = $0 }.store(in: &bag)
        hope(db.count.subscriptions) == 2

        bag.removeAll()
        hope(db.count.subscriptions) == 0
    }

    func test_with_Published_store() throws {
        
        class Database: Geyser {
            
            typealias Fork = JSON.Fork

            @Published var store: JSON = .init()
            let depth = 1
            
            func gush(of route: JSON.Route) -> Flow<JSON> {
                $store.flow(of: route)
            }
            
            func source(of route: JSON.Route) throws -> JSON.Route {
                guard route.count >= depth else {
                    throw "Can flow only at depth \(depth)"
                }
                return Route(route.prefix(depth))
            }
        }

        var count = (a: 0, b: 0)
        
        var a: Result<Int, Error> = .failure("😱") { didSet { count.a += 1 } }
        var b: Result<Int, Error> = .failure("😱") { didSet { count.b += 1 } }
        
        let pond = Pond(geyser: Database())

        try pond.geyser.store.set(1, "two", 3, to: ["a": 0, "b": 0])

        // TODO: pass all the hopes without the removeDuplicates operator.
        // These ↓ reflect the fact that `store.set` is causing the geyser to gush,
        // which in turn causes subscribers of all the fields within the gush to be called.
        pond.flow(of: 1, "two", 3, "a").removeDuplicates().sink{ a = $0 }.store(in: &bag)
        pond.flow(of: 1, "two", 3, "b").removeDuplicates().sink{ b = $0 }.store(in: &bag)

        hope(a) == 0
        hope(b) == 0
        hope(count.a) == 1
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "a", to: 1)

        hope(a) == 1
        hope(b) == 0
        hope(count.a) == 2
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "a", to: 2)

        hope(a) == 2
        hope(b) == 0
        hope(count.a) == 3
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "a", to: 3)

        hope(a) == 3
        hope(b) == 0
        hope(count.a) == 4
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "b", to: 3)

        hope(a) == 3
        hope(b) == 3
        hope(count.a) == 4
        hope(count.b) == 2
    }

    func test_with_DeltaJSON_store() throws {

        var count = (a: 0, b: 0)
        
        var a: Result<Int, Error> = .failure("😱") { didSet { count.a += 1 } }
        var b: Result<Int, Error> = .failure("😱") { didSet { count.b += 1 } }
        
        let pond = Pond(geyser: Database())

        try pond.geyser.store.set(1, "two", 3, to: ["a": 0, "b": 0])

        // TODO: pass all the hopes without the removeDuplicates operator.
        // These ↓ reflect the fact that `store.set` is causing the geyser to gush,
        // which in turn causes subscribers of all the fields within the gush to be called.
        pond.flow(of: 1, "two", 3, "a").removeDuplicates().sink{ a = $0 }.store(in: &bag)
        pond.flow(of: 1, "two", 3, "b").removeDuplicates().sink{ b = $0 }.store(in: &bag)

        hope(a) == 0
        hope(b) == 0
        hope(count.a) == 1
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "a", to: 1)

        hope(a) == 1
        hope(b) == 0
        hope(count.a) == 2
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "a", to: 2)

        hope(a) == 2
        hope(b) == 0
        hope(count.a) == 3
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "a", to: 3)

        hope(a) == 3
        hope(b) == 0
        hope(count.a) == 4
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "b", to: 3)

        hope(a) == 3
        hope(b) == 3
        hope(count.a) == 4
        hope(count.b) == 2
    }
    
    func test_stress() throws {
        
        let routes = JSON.Fork.randomRoutes(
            count: 1000,
            in: Array(0...2),
            and: "abc".map(String.init),
            bias: 0.1,
            length: 5...7,
            seed: 502645 // Int.random(in: 1000...1_000_000).peek("✅")
        )

        let pond = Pond(geyser: Database())
        let json: DeltaJSON = .init()
        
        for route in Set(routes.compactMap(\.first)) {
            pond.flow(of: route, as: JSON.self).sink{ result in
                try? json.set(route, to: result.get())
            }.store(in: &bag)
        }
        
        let g = DispatchGroup()
        
        let q = (1...4).map{ i in
            DispatchQueue(label: "q[\(i)]", attributes: .concurrent)
        }
        
        for (i, route) in routes.enumerated() {
            g.enter()
            q[i % q.count].asyncAfter(deadline: .now() + .random(in: 0...0.01)) {
                try! pond.geyser.store.set(route, to: i)
                g.leave()
            }
        }

        hope(g.wait(timeout: .now() + 1)) == .success

        hope(json.debugDescription) == pond.geyser.store.debugDescription
    }
}

extension Pond™ {

    class Database: Geyser {
        
        typealias Fork = JSON.Fork

        let store: DeltaJSON = .init()
        
        let depth: Int
        
        private(set) var count = (
            subscriptions: 0,
            ()
        )
        
        public init(depth: Int = 1) {
            self.depth = depth
        }
        
        func gush(of route: JSON.Route) -> Flow<JSON> {
            store.flow(of: route, as: JSON.self)
                .handleEvents(
                    receiveSubscription: { _ in self.count.subscriptions += 1 },
                    receiveCancel: { self.count.subscriptions -= 1 }
                )
                .eraseToAnyPublisher()
        }
        
        func source(of route: JSON.Route) throws -> JSON.Route {
            guard route.count >= depth else {
                throw "Can flow only at depth \(depth)"
            }
            return Route(route.prefix(depth))
        }
    }
}
