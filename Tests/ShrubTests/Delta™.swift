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
    
    func test_flowFlatMap() throws {
        
        let json = CurrentValueSubject<JSONResult, Never>(^0)
        
        var result: JSONResult = .failure("😱")

        json.flowFlatMap{ o in Just(o).flow() }.sink{ result = $0 }.store(in: &bag)

        json.value = ^4.0
        hope(try result.get().cast()) == 4.0

        json.value = .failure("😱")

        json.value = ^5.0
        hope(try result.get().cast()) == 5.0
    }
}

extension Delta™ {
    
    func test_pond() throws {
        
        var result: Result<Int, Error> = .failure("😱")
        
        let pond = Pond()
        
        let route: JSONRoute = ["one", "two", "three"]
        
        pond.db.store[route] = 4
        
        pond[route].sink{ result = $0 ¶ "✅💛 1" }.store(in: &bag)
        pond[route].sink{ result = $0 ¶ "✅💛 2" }.store(in: &bag)
        pond[route].sink{ result = $0 ¶ "✅💛 3" }.store(in: &bag)
        
        hope(result) == 4
        
        pond.db.depth = 2
        
        pond.db.store[route] = 5
//
//        hope(result) == 5
        
//        pond.db.store[route] = 6
//
//        hope(result) == 6
//
//        pond.db.store[route] = 7
//
//        hope(result) == 7
        
        var promise = expectation()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            promise.fulfill()
//            self.bag.removeAll()
//        }
//
//        wait(for: promise, timeout: 1)
//
//        promise = expectation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise.fulfill()
        }
        
        wait(for: promise, timeout: 1)
    }
    
    class Pond: Delta {
        
        let db = Database()
        
        @Published var store: JSON = nil
        
        var sources: [JSONRoute: AnyCancellable] = [:]
        
        var flows: [JSONRoute: Flow<JSON>] = [:]
        
        var source: [JSONRoute: Flow<Int>] = [:]

        func flow<A>(of route: JSONRoute, as: A.Type) -> Flow<A> {
            
            _ = source[route, default: self.db.source(of: route)]
                
            
            
            return db.source(of: route).flowFlatMap{ [weak self] prefixCount -> Flow<A> in
                guard let self = self else { throw "🗑".error() }
                let source = Array(route.prefix(prefixCount))
                if !self.sources.keys.contains(source) {
                    self.sources[source] = self.db.flow(of: source, as: JSON.self).sink{ json in
                        self.store[source] = try? json.get()
                    }
                }
                return self.$store.flow(of: route, as: A.self)
            }
        }
    }

    class Database: Tributary {

        @Published var store: JSON = nil
        @Published var depth = 1
        
        func flow<A>(of route: JSONRoute, as: A.Type) -> Flow<A> {
            guard route.count == depth else {
                return Fail(error: "Can flow only at depth \(depth)").flow()
            }
            return $store.flow(of: route)
        }
        
        func source(of route: JSONRoute) -> Flow<PrefixCount> {
            $depth.tryMap{ depth in
                let source = Array(route.prefix(depth))
                guard source.count == depth else {
                    throw "Can flow only at depth \(depth)".error()
                }
                return depth
            }
            .flow()
        }
    }
}
