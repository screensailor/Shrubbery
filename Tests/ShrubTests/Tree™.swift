class Tree™: Hopes {
    
    func test() throws {
        
        var tree = Tree<CodingIndex, Int>()
        hope(tree[]) == nil

        tree[] = 0
        hope(tree[]) == 0
        
        tree[value: 1] = 1
        hope(tree[value: 1]) == 1
        
        tree[value: 1, 2, 3] = 3
        hope(tree[value: 1, 2, 3]) == 3
        
        tree[value: 1, "2", 3] = 3
        hope(tree[value: 1, "2", 3]) == 3
        
        tree[value: 1] = nil
        hope(tree[value: 1, 2, 3]) == 3
        hope(tree[value: 1, "2", 3]) == 3
        
        tree[1] = nil
        hope(tree[value: 1, 2, 3]) == nil
        hope(tree[value: 1, "2", 3]) == nil
    }
    
    func test_traverse() throws {
        
        var tree = Tree<Int, Int>()
        
        var traversal: [(route: [Int], value: Int)] = []
        
        for x in 1...5 {
            for y in 1...5 {
                for z in 1...5 {
                    tree[value: x, y, z] = x * y * z
                    traversal.append(([x, y, z], x * y * z))
                }
            }
        }
        
        tree.traverse { route, value in
            guard let value = value else { return }
            print(
                "✅",
                route.map(\.description).joined(separator: " * "),
                "=",
                value
            )
        }
    }
}
