class Pond™: Hopes {
    
    private var bag: Set<AnyCancellable> = []
    
    func test() throws {
        
        var count = (a: 0, b: 0)
        
        var a: Result<Int, Error> = .failure("😱") { didSet { count.a += 1 } }
        var b: Result<Int, Error> = .failure("😱") { didSet { count.b += 1 } }
        
        var pond = Pond(geyser: Database())

        try pond.geyser.store.set(["a": 0, "b": 0], at: 1, "two", 3)

        pond.flow(of: 1, "two", 3, "a").sink{ a = $0 }.store(in: &bag)
        pond.flow(of: 1, "two", 3, "b").sink{ b = $0 }.store(in: &bag)
        
        hope.for(0.01)
        hope(a) == 0
        hope(b) == 0
        hope(count.a) == 1
        hope(count.b) == 1

        try pond.geyser.store.set(1, at: 1, "two", 3, "a")
        hope.for(0.01)
        hope(a) == 1
        hope(b) == 0
        hope(count.a) == 2
        hope(count.b) == 1

        try pond.geyser.store.set(2, at: 1, "two", 3, "a")
        hope.for(0.01)
        hope(a) == 2
        hope(b) == 0
        hope(count.a) == 3
        hope(count.b) == 1

        try pond.geyser.store.set(3, at: 1, "two", 3, "a")
        hope.for(0.01)
        hope(a) == 3
        hope(b) == 0
        hope(count.a) == 4
        hope(count.b) == 1

        try pond.geyser.store.set(3, at: 1, "two", 3, "b")
        hope.for(0.01)
        hope(a) == 3
        hope(b) == 3
        hope(count.a) == 4
        hope(count.b) == 2

        pond = Pond(geyser: Database())
    }
}

extension Pond™ {

    class Database: Geyser {
        
        typealias Fork = JSON.Fork

        @Published var store: JSON = nil
        @Published var depth = 1
        
        func gush(of route: JSON.Route) -> Flow<JSON> {
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
