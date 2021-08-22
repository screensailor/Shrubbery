public protocol Routed {
    
    associatedtype Key: Hashable

    typealias Fork = EitherType<Int, Key>
    typealias Route = [Fork]
}
