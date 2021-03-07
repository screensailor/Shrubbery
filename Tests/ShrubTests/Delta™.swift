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

        let json: CurrentValueSubject<JSON, Never> = nil
        
        var result: Result<Int, Error> = .failure("😱")
        
        json["one", 2, "three"].sink{ result = $0 }.store(in: &bag)
        
        json.value["one", 2, "three"] = 4
        
        hope(result) == 4
    }
}

extension Delta™ {
    
    func test_pond() throws {
        
        var result: Result<Int, Error> = .failure("😱")
        
        let pond = Pond()
        
        let route: JSONRoute = ["one", "two", "three"]
        
        pond[route].sink{ result = $0.peek("✅❓💛 1") }.store(in: &bag)
        pond[route].sink{ result = $0.peek("✅❓💛 2") }.store(in: &bag)
        pond[route].sink{ result = $0.peek("✅❓💛 3") }.store(in: &bag)

        pond.db.store[route] = 4
        
        hope(result) == 4
        
        pond.db.store[route] = 5
        
        hope(result) == 5
        
        pond.db.store[route] = 6
        
        hope(result) == 6
        
        pond.db.store[route] = 7
        
        hope(result) == 7

        bag.removeAll()
    }
    
    class Pond: Delta {
        
        let db = Database()
        
        @Published var store: JSON = nil
        
        var sources: [JSONRoute: AnyCancellable] = [:]
        
        func flow<A>(of route: JSONRoute, as: A.Type) -> Flow<A> {
            return db.source(of: route)
                .print("✅ 0").flowFlatMap{ [weak self] source -> Flow<A> in
                    guard let self = self else { throw "🗑".error() }
                    guard !self.sources.keys.contains(source) else {
                        return self.$store.flow(of: route, as: A.self)
                    }
                    let s = self.db.flow(of: source, as: JSON.self).share()
                    self.sources[source] = s.print("✅ 2").sink{ o in
                        self.store[source] = try? o.get()
                    }
                    return s.first().flowFlatMap{ _ in
                        self.$store.flow(of: route, as: A.self)
                    }
                }
                .handleEvents(
                    receiveSubscription: { o in
                        print("✅❓receiveSubscription", route, o)
                    },
//                    receiveOutput: { o in
//                        print("✅❓receiveOutput", route, o)
//                    },
                    receiveCompletion: { o in
                        print("✅❓receiveCompletion", route, o)
                    },
                    receiveCancel: {
                        print("✅❓receiveCancel", route)
                    },
                    receiveRequest: { o in
                        print("✅❓receiveRequest", route, o)
                    }
                )
                .eraseToAnyPublisher()
        }
    }

    class Database: Tributary {

        @Published var store: JSON = nil
        
        func flow<A>(of route: JSONRoute, as: A.Type) -> Flow<A> {
            guard route.count == 1 else {
                return Fail(error: "Can flow only at depth 1").flow()
            }
            return $store.flow(of: route)
        }
        
        func source(of route: JSONRoute) -> Flow<JSONRoute> {
            guard let index = route.first else {
                return Fail(error: "Can flow only at depth 1").flow()
            }
            return Just([index]).flow()
        }
    }
}
