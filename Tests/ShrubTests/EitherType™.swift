class EitherType™: Hopes {
    
    func test() throws {
        
        let x: EitherType<Int, String> = .init(5)
        let y: EitherType<String, Int> = .init(5)
        
        hope.true(x == y)
    }
}

