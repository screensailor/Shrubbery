class Tree™: Hopes {
    
    func test() throws {
        
        let t = Tree<CodingIndex, Int>(value: 1)
        
        hope(t[]?.value) == 1
        
    }
}
