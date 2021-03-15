class StressIt™: Hopes {
    
    var json: JSON = nil
    var bag: Set<AnyCancellable> = []
    
    @available(iOS 14.0, *)
    func test() throws {
        
    }
}

extension StressIt™ {

    class Database: Geyser {
        
        typealias Fork = JSON.Fork

        @Published var store: JSON = nil
        var depth = 1
        var delay: ClosedRange<Double> = 0...0
        var queue = DispatchQueue.main
        
        func gush(of route: JSON.Route) -> Flow<JSON> {
            assert(Thread.isMainThread)
            let delay = Double.random(in: self.delay)
            return $store.flow(of: route)
                .delay(for: .seconds(delay), scheduler: queue)
                .eraseToAnyPublisher()
        }
        
        func source(of route: JSON.Route) throws -> JSON.Route.Index {
            guard route.count >= depth else {
                throw GeyserError.badRoute(
                    route: route,
                    message: "Can flow only at depth \(depth)"
                )
            }
            return depth
        }
    }
}
