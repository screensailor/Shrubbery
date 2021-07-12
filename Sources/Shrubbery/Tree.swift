public struct Tree<Key, Value> where Key: Hashable {
    
    public var value: Value?
    public var branches: [Key: Tree]
    
    public init(value: Value? = nil, branches: [Key: Tree] = [:]) {
        self.value = value
        self.branches = branches
    }
}

extension Tree {
    
    public subscript(route: Key..., inserting defaultTree: Tree) -> Tree {
        mutating get {
            self[route, inserting: defaultTree]
        }
    }
    
    public subscript<Keys>(route: Keys, inserting defaultTree: Tree) -> Tree
    where
        Keys: Collection,
        Keys.Element == Key
    {
        mutating get {
            self[route] ?? {
                self[route] = defaultTree
                return defaultTree
            }()
        }
    }
    
    public subscript(value route: Key..., inserting defaultValue: Value) -> Value {
        mutating get {
            self[value: route, inserting: defaultValue]
        }
    }
    
    public subscript<Keys>(value route: Keys, inserting defaultValue: Value) -> Value
    where
        Keys: Collection,
        Keys.Element == Key
    {
        mutating get {
            self[value: route] ?? {
                self[value: route] = defaultValue
                return defaultValue
            }()
        }
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
                return self
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

extension Tree where Key: Comparable {

    // TODO:❗️breadth vs. depth first
    /// Depth first traversal
    public func traverse(sorted: Bool = false, yield: ((route: [Key], value: Value?)) -> ()) {
        Self.traverse(sorted: sorted, route: [], tree: self, yield: yield)
    }

    private static func traverse(sorted: Bool = false, route: [Key], tree: Tree, yield: ((route: [Key], value: Value?)) -> ()) {
        yield((route, tree.value))
        if sorted {
            for (key, tree) in tree.branches.sorted(by: { $0.key < $1.key }) {
                traverse(sorted: sorted, route: route + [key], tree: tree, yield: yield)
            }
        } else {
            for (key, tree) in tree.branches {
                traverse(sorted: sorted, route: route + [key], tree: tree, yield: yield)
            }
        }
    }
}

extension Tree: CustomStringConvertible {
    
    public var description: String {
        "\(Self.self)(value: \(String(describing: value)) branches count: \(branches.count))"
    }
}

extension Tree: CustomDebugStringConvertible where Key: Comparable {

    public var debugDescription: String {
        var o = "\(Self.self)"
        traverse(sorted: true) { route, value in
            let t = repeatElement("\t|", count: route.count + 1).joined()
            o += "\n\(t)\(route):\n\(t)\(value.map(String.init(describing:)) ?? "nil")"
        }
        return o
    }
}
