@dynamicMemberLookup
public struct Tree<Key, Value> where Key: Hashable {
    
    public let value: Value
    public let branches: [Key: Tree]
    
    public init(value: Value, branches: [Key: Tree] = [:]) {
        self.value = value
        self.branches = branches
    }
}

extension Tree {
    
    public subscript<A>(dynamicMember keyPath: KeyPath<Value, A>) -> A {
        value[keyPath: keyPath]
    }
}

extension Tree {
    
    public subscript(route: Key...) -> Tree? {
        get { self[route] }
        set { self[route] = newValue }
    }

    public subscript(route: [Key]) -> Tree? {
        get {
            guard let key = route.first else {
                return Tree(value: value)
            }
            fatalError()
        }
        set {
            
        }
    }
}
