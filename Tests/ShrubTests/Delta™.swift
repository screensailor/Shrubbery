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
        
        pond["one", "two", "three"].sink{ result = $0 }.store(in: &bag)
        
        pond.db.store["one", "two", "three"] = 4
        
        hope(result) == 4
    }
    
    class Pond: Delta {
        
        let db = Database()
        
        @Published var store: JSON = nil
        
        func flow<A>(of route: Route<JSON.Key>, as: A.Type) -> Flow<A> {
            var source = route
            return db.source(of: source).print("✅ 1").flatMap{ [weak self] o -> Flow<JSON> in
                guard let self = self else { return Just(.failure("😱")).eraseToAnyPublisher() }
                do {
                    source = try o.get()
                    return self.db.flow(of: source, as: JSON.self)
                } catch {
                    return Just(.failure("\(error)")).eraseToAnyPublisher()
                }
            }.print("✅ 2").flatMap{ [weak self] o -> Flow<A> in
                guard let self = self else { return Just(.failure("😱")).eraseToAnyPublisher() }
                do {
                    try self.store.set(o.get(), at: source)
                    return self.$store.flow(of: route, as: A.self)
                } catch {
                    return Just(.failure("\(error)")).eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
        }
    }

    class Database: Tributary {

        @Published var store: JSON = nil
        
        func flow<A>(of route: JSONRoute, as: A.Type) -> Flow<A> {
            guard route.count == 1 else {
                return Just(.failure("Can flow only at depth 1")).eraseToAnyPublisher()
            }
            return $store.flow(of: route)
        }
        
        func source(of route: JSONRoute) -> Flow<JSONRoute> {
            guard let index = route.first else {
                return Just(.failure("Can flow only at depth 1")).eraseToAnyPublisher()
            }
            return Just(.success([index])).eraseToAnyPublisher()
        }
        
        func route(to route: JSONRoute) -> Flow<JSONRoute> {
            Just(.success(route)).eraseToAnyPublisher()
        }
    }
}
