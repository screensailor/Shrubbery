class Pond™: Hopes {
    
    private var bag: Set<AnyCancellable> = []
    
    func test() throws {

    }
}

extension Pond™ {

    class Database: Geyser {

        @Published var store: JSON = nil
        @Published var depth = 1
        
        func gush(of route: JSONRoute) -> Flow<JSON> {
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
