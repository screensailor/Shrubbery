class Optional™: Hopes {
    
    func test_isNil() throws {
        
        hope(isNilAfterFlattening(Optional<Any>.some(Int?.none as Any))) == true
        
        let a: Int???? = nil
        let any = a as Any

        hope(isNilAfterFlattening(any)) == true
        
        let array = [Int?.none as Any, 1, 2, Any?.none as Any, 4, Any?.none as Any]
        for (i, e) in array.enumerated() {
            switch i {
            case 0: hope(isNilAfterFlattening(e)) == true
            case 1: hope(isNilAfterFlattening(e)) == false
            case 5: hope(isNilAfterFlattening(e)) == true
            default: break
            }
        }
    }
    
    func test_flattenOptionality_of_some() throws {
        
        let a: Int???? = 4
        let b = a!
        let aƒ = try flattenOptionality(of: a).hopefully()
        
        assert(type(of: b) == Int???.self)
        
        hope.true(type(of: aƒ) == Int.self)
        
        let any = a as Any
        let anyƒ = try flattenOptionality(of: any).hopefully()
        hope.true(type(of: anyƒ) == Int.self)

        let ºany = a as Any?
        let ºanyƒ = try flattenOptionality(of: ºany).hopefully()
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
