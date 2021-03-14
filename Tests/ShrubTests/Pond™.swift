class Pond™: Hopes {
    
    private var bag: Set<AnyCancellable> = []
    
    func test() throws {

        let pond = Pond(source: Database())
        
        var count = (a: 0, b: 0)
        
        var a: Result<Int, Error> = .failure("😱") { didSet { count.a += 1 } }
        var b: Result<Int, Error> = .failure("😱") { didSet { count.b += 1 } }
        
        pond.flow(of: 1, "two", 3, "a").sink{ a = $0 ¶ "✅ a" }.store(in: &bag)
        pond.flow(of: 1, "two", 3, "b").sink{ b = $0 ¶ "✅ b" }.store(in: &bag)
        
        hope.for(0.01)
        
        hope.throws(try a.get())
        hope.throws(try b.get())

        try pond.source.store.set(1, at: 1, "two", 3, "a")
        
        hope.for(0.01)
        
        hope(a) == 1
    }
}

extension Pond™ {

    class Database: Geyser {

        typealias Key = JSONRoute
        typealias Value = JSON

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
                    throw GeyserError.badKey(
                        key: route,
                        message: "Can flow only at depth \(depth)"
                    )
                }
                return depth
            }
            .eraseToAnyPublisher()
        }
    }
}
