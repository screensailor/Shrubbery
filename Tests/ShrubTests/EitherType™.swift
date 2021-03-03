class EitherType™: Hopes {
    
    func test_subscript() throws {
        
        var index: CodingIndex
            
        index = 5
        
        hope(index[Int]) == 5
        
        index = "👋"
        
        hope(index[String]) == "👋"
    }
    
    func test_AB_BA_equatability() throws {
        
        let x: EitherType<Int, String> = .init(5)
        let y: EitherType<String, Int> = .init(5)
        
        hope.true(x == y)
    }
}

