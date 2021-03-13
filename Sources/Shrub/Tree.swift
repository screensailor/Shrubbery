public struct Tree<Key, Value> where Key: Hashable {
    
    public let value: Value
    public let branches: [Key: Tree]
    
    public init(value: Value, branches: [Key: Tree] = [:]) {
        self.value = value
        self.branches = branches
    }
}

extension Tree {
    
    public subscript(route: Key...) -> Tree? {
        self[route]
    }
    
    public subscript(route: [Key]) -> Tree? {
        fatalError()
    }
}
