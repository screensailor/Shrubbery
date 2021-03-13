class Pond™: Hopes {
    
    private var bag: Set<AnyCancellable> = []
    
    func test() throws {

    }
}

extension Pond™ {
    
    class Pond: Delta {
        
        var store: DeltaJSON = .init()
        
        let a = Database()
        let b = Database()
        let c = Database()
        
        private var bag: Set<AnyCancellable> = []

        func flow<A>(of route: JSONRoute, as: A.Type) -> Flow<A> {
            
            let a = self.a.source(of: route)
                .tryMap{ o in Array(route.prefix(o)) }
                .flatMap{ o in self.a.flow(of: o, as: JSON.self) }
                .catch{ o in Just(.failure(o)) }

            a.sink{ result in
                
            }.store(in: &bag)
            
            
            return store.flow(of: route)
        }
    }

    class Database: Tributary {

        @Published var store: JSON = nil
        @Published var depth = 1
        
        func flow<A>(of route: JSONRoute, as: A.Type) -> Flow<A> {
            $depth.map{ [weak self] depth in
                Result{
                    guard let self = self else {
                        throw "🗑".error()
                    }
                    guard route.count == depth else {
                        throw "Can flow only at depth \(depth)".error()
                    }
                    return try self.store.get(route)
                }
            }
            .merge(with: $store.flow(of: route))
            .eraseToAnyPublisher()
        }
        
        func source(of route: JSONRoute) -> AnyPublisher<PrefixCount, Error> {
            $depth.tryMap{ depth in
                guard route.count >= depth else {
                    throw "Can flow only at depth \(depth)".error()
                }
                return depth
            }
            .eraseToAnyPublisher()
        }
    }
}
