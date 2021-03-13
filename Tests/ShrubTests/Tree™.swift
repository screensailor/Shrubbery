class Tree™: Hopes {
    
    func test() throws {
        
        var t = Tree<CodingIndex, Int>()
        hope(t[]?.value) == nil

        t[] = Tree(value: 0)
        hope(t[1]?.value) == nil
        
        t[1] = Tree(value: 1)
        hope(t[1]?.value) == 1
        
        t[1, 2, 3] = Tree(value: 3)
        hope(t[1, 2, 3]?.value) == 3
    }
}
