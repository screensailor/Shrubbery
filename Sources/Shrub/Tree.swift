@dynamicMemberLookup
public struct Tree<Key, Value> where Key: Hashable {
    
    public var value: Value?
    public var branches: [Key: Tree]
    
    public init(value: Value? = nil, branches: [Key: Tree] = [:]) {
        self.value = value
        self.branches = branches
    }
}

extension Tree {
    
    public subscript<A>(dynamicMember keyPath: KeyPath<Value, A>) -> A? {
        value?[keyPath: keyPath]
    }
}

extension Tree {
    
    public subscript(route: Key...) -> Tree? {
        get { self[route] }
        set { self[route] = newValue }
    }

    public subscript<Keys>(route: Keys) -> Tree?
    where
        Keys: Collection,
        Keys.Element == Key
    {
        get {
            guard let key = route.first else {
                return Tree(value: value)
            }
            return branches[key]?[route.dropFirst()]
        }
        set {
            guard let key = route.first else {
                value = newValue?.value
                branches = newValue?.branches ?? [:]
                return
            }
            branches[key, default: Tree()][route.dropFirst()] = newValue
        }
    }
}
