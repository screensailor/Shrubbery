class Tree™: Hopes {
    
    func test() throws {
        
        var t = Tree<CodingIndex, Int>()
        hope(t[]) == nil

        t[] = 0
        hope(t[]) == 0
        
        t[value: 1] = 1
        hope(t[value: 1]) == 1
        
        t[value: 1, 2, 3] = 3
        hope(t[value: 1, 2, 3]) == 3
        
        t[value: 1, "2", 3] = 3
        hope(t[value: 1, "2", 3]) == 3
        
        t[value: 1] = nil
        hope(t[value: 1, 2, 3]) == 3
        hope(t[value: 1, "2", 3]) == 3
        
        t[1] = nil
        hope(t[value: 1, 2, 3]) == nil
        hope(t[value: 1, "2", 3]) == nil
    }
}
