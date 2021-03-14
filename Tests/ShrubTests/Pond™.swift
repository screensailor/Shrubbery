class Pond™: Hopes {
    
    private var bag: Set<AnyCancellable> = []
    
    func test() throws {
        
        var count = (a: 0, b: 0)
        
        var a: Result<Int, Error> = .failure("😱") { didSet { count.a += 1 } }
        var b: Result<Int, Error> = .failure("😱") { didSet { count.b += 1 } }
        
        var pond = Pond(geyser: Database())

        try pond.geyser.store.set(1, "two", 3, to: ["a": 0, "b": 0])

        // TODO: pass all the hopes without the removeDuplicates operator
        // These ↓ reflect the fact that `store.set` is causing the geyser to gush,
        // which in turn causes subscribers of all the fields within the gush to be called.

        pond.flow(of: 1, "two", 3, "a").removeDuplicates().sink{ a = $0 }.store(in: &bag)
        pond.flow(of: 1, "two", 3, "b").removeDuplicates().sink{ b = $0 }.store(in: &bag)
        
        hope.for(0.01)
        hope(a) == 0
        hope(b) == 0
        hope(count.a) == 1
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "a", to: 1)
        hope.for(0.01)
        hope(a) == 1
        hope(b) == 0
        hope(count.a) == 2
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "a", to: 2)
        hope.for(0.01)
        hope(a) == 2
        hope(b) == 0
        hope(count.a) == 3
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "a", to: 3)
        hope.for(0.01)
        hope(a) == 3
        hope(b) == 0
        hope(count.a) == 4
        hope(count.b) == 1

        try pond.geyser.store.set(1, "two", 3, "b", to: 3)
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
            $store.flow(of: route)
                .delay(for: 0, scheduler: DispatchQueue.main)
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
