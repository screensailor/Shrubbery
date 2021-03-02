@_exported import Shrub
@_exported import Hope
@_exported import Peek

class Shrub™: Hopes {
    
    func test_subscript() throws { 
        
        var o: JSON
            
        o = nil
        o = []
        o = [:]
        
        o[] = "👋"
        hope(o[]) == "👋"
        
        o["one"] = 1
        hope(o["one"]) == 1
        
        o["one", 2] = 2
        hope(o["one", 2]) == 2
        
        o["one", 3] = nil
        hope(o["one"]) == [nil, nil, 2] // did not append
        
        o["one", 2] = nil
        hope.true(isNilAfterFlattening(o["one"])) // none left
        
        o["one", "two"] = nil
        hope.true(isNilAfterFlattening(o["one", "two"]))
    }
    
    func test_expressible() throws {
        
        let o: JSON = [
            "one": [
                "two": ^[
                    3, 4, 5
                ]
            ],
            "and": ^["so", "on", "..."]
        ]

        hope(o["and", 2]) == "..."
    }
}

extension Shrub™ {
    
    func test_Shub_get() throws {

        var any: Any = 1
        try hope(Shrub<String, Any>.get([], in: any) as? Int) == 1
        hope.throws(try Shrub.get("one", in: any))
        
        any = ["one": 1]
        try hope(Shrub.get("one", in: any) as? Int) == 1
        hope.throws(try Shrub.get("two", in: any))
        
        any = ["one": ["two": ["three": 3]]]
        try hope(Shrub.get("one", "two", "three", in: any) as? Int) == 3
        
        any = [any, any, any]
        try hope(Shrub.get(1, "one", "two", "three", in: any) as? Int) == 3
    }
    
    func test_Shrub_set() throws {
        
        var any: Any = 1
        try Shrub<String, Any>.set(2, at: [], in: &any)
        hope(any as? Int) == 2
        
        any = ["one": 1]
        try Shrub.set(2, at: "two", in: &any)
        try hope(Shrub.get("two", in: any) as? Int) == 2
        
        any = [:]
        try Shrub.set(3, at: "one", "two", "three", in: &any)
        try hope(Shrub.get("one", "two", "three", in: any) as? Int) == 3
        
        any = 0
        try Shrub.set("😃", at: 2, "three", 4, "five", in: &any)
        try hope(Shrub.get(2, "three", 4, "five", in: any) as? String) == "😃"
    }
}
