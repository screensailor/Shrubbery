class StressIt™: Hopes {
    
    var bag: Set<AnyCancellable> = []
    
    @available(iOS 14.0, *)
    func test() throws {
        
        let routes = JSON.Fork.randomRoutes(
            count: 2,
            in: Array(0...2),
            and: "abc".map(String.init),
            bias: 0.1,
            length: 5...7,
            seed: 502645 // Int.random(in: 1000...1_000_000).peek("✅")
        )

        let pond = Pond(geyser: Database())
        let json: DeltaJSON = .init()
        
        for route in routes {
            pond.flow(of: route, as: JSON.self).sink{ result in
                debugPrint("✅", route, pond.geyser.store, result)
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
                [route] in
                print("✅❗️", route)
                try! pond.geyser.store.set(route, to: i)
                g.leave()
            }
        }

        hope(g.wait(timeout: .now() + 1)) == .success
        
        hope.for(0.1)

        hope(json.debugDescription) == pond.geyser.store.debugDescription
    }
}

extension StressIt™ {

    class Database: Geyser {
        
        typealias Fork = JSON.Fork

        let store: DeltaJSON = .init()
        
        var depth = 1
        
        func gush(of route: JSON.Route) -> Flow<JSON> {
            store.flow(of: route, as: JSON.self)
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
