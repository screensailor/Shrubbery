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

        tree[1, 2] = Tree(
            value: nil,
            branches: [
                1: Tree(value: 1),
                2: Tree(value: 2),
                "a": Tree(value: 3),
                "b": Tree(value: 4),
            ]
        )
        hope(tree[value: 1, 2, 1]) == 1
        hope(tree[value: 1, 2, 2]) == 2
        hope(tree[value: 1, 2, "a"]) == 3
        hope(tree[value: 1, 2, "b"]) == 4

        tree[1, 2] = Tree(
            value: nil,
            branches: [
                "a": Tree(value: 3),
                "b": Tree(value: 5)
            ]
        )
        hope(tree[value: 1, 2, "a"]) == 3
        hope(tree[value: 1, 2, "b"]) == 5
    }
    
    func test_traverse() throws {
        
        var tree = Tree<Int, Int>()
        
        var traversal: [[Int]: Int] = [:]
        
        for x in 1...5 {
            for y in 1...5 {
                for z in 1...5 {
                    tree[value: x, y, z] = x * y * z
                    traversal[[x, y, z]] = x * y * z
                }
            }
        }
        
        tree.traverse { route, value in
            if traversal[route] == value {
                traversal.removeValue(forKey: route)
            }
        }
        
        hope(traversal.count) == 0
    }
}
