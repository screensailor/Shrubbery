class Optional™: Hopes {
    
    func test_isNil() throws {
        
        hope.true(isNil(Optional<Any>.some(Int?.none as Any)))
        
        let a: Int???? = nil
        let any = a as Any
        
        assert(any != nil)

        hope.true(isNil(any))
        
        let array = [Int?.none as Any, 1, 2, Any?.none as Any, 4, Any?.none as Any]
        for (i, e) in array.enumerated() {
            switch i {
            case 0: hope.true(isNil(e))
            case 1: hope.false(isNil(e))
            case 5: hope.true(isNil(e))
            default: break
            }
        }
    }
    
    func test_flattenOptionality_of_some() throws {
        
        let a: Int???? = 4
        let b = a!
        let aƒ = flattenOptionality(of: a)!
        
        assert(type(of: b) == Int???.self)
        
        hope.true(type(of: aƒ) == Int.self)
        
        let any = a as Any
        let anyƒ = flattenOptionality(of: any)!
        hope.true(type(of: anyƒ) == Int.self)

        let ºany = a as Any?
        let ºanyƒ = flattenOptionality(of: ºany)!
        hope.true(type(of: ºanyƒ) == Int.self)
    }
    
    func test_flattenOptionality_of_none() throws {
        
        let a = Optional<Any>.some(Int?.none as Any)
        
        let aƒ = flattenOptionality(of: a)
        
        switch aƒ {
        case .none: break
        case .some: hope.less("aƒ should not be .some")
        }
    }
}
