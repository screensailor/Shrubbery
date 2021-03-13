public struct Tree<Key, Value> where Key: Hashable {
    
    public var value: Value?
    public var branches: [Key: Tree]
    
    public init(value: Value? = nil, branches: [Key: Tree] = [:]) {
        self.value = value
        self.branches = branches
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

extension Tree {
    
    public subscript(value route: Key...) -> Value? {
        get { self[value: route] }
        set { self[value: route] = newValue }
    }

    public subscript<Keys>(value route: Keys) -> Value?
    where
        Keys: Collection,
        Keys.Element == Key
    {
        get { self[route]?.value }
        set {
            guard let key = route.first else {
                value = newValue
                return
            }
            branches[key, default: Tree()][value: route.dropFirst()] = newValue
        }
    }
}

extension Tree {
    
    // TODO:❗️breadth vs. depth first
    /// Depth first traversal
    public func traverse(yield: ((route: [Key], value: Value?)) -> ()) {
        Self.traverse(route: [], tree: self, yield: yield)
    }
    
    private static func traverse(route: [Key], tree: Tree, yield: ((route: [Key], value: Value?)) -> ()) {
        yield((route, tree.value))
        for (key, tree) in tree.branches {
            traverse(route: route + [key], tree: tree, yield: yield)
        }
    }
}
