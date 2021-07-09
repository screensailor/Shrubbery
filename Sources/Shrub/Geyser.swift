public protocol Geyser {

    associatedtype Fork
    typealias Route = [Fork]
    typealias EndIndex = Route.Index

    associatedtype Value
    
    func gush(of: Route) -> Flow<Value>
    func source(of: Route) throws -> EndIndex // TODO:❗️-> AnyPublisher<Route.Index, Error>
}

public enum GeyserError<Route>: Error {
    case badRoute(route: Route, message: String)
}

extension Geyser where Self: Delta, Value: Shrubbery {
    
    public func flow<A>(of route: Route, as: A.Type) -> Flow<A> {
        gush(of: route).map{ o in Result{ try o.get().as(A.self) } }.eraseToAnyPublisher()
    }
}

