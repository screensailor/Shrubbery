@_exported import Hope
@_exported import Peek
@_exported import Shrub
@_exported import Combine
@_exported import CombineSchedulers

extension String: Error {}

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
        
        let o: JSON = ^[
            "one": ^[
                "two": [
                    3, 4, 5
                ]
            ],
            "and": ["so", "on", "..."]
        ]

        hope(o["and", 2]) == "..."
    }
}

extension Shrub™ {

    func test_ShrubAny_get() throws {

        var any: Any = 1
        try hope(Shrub<String, Any>.get([], in: any) as? Int) == 1
        hope.throws(try ShrubAny.get("one", in: any))

        any = ["one": 1]
        try hope(ShrubAny.get("one", in: any) as? Int) == 1
        hope.throws(try ShrubAny.get("two", in: any))

        any = ["one": ["two": ["three": 3]]]
        try hope(ShrubAny.get("one", "two", "three", in: any) as? Int) == 3

        any = [any, any, any]
        try hope(ShrubAny.get(1, "one", "two", "three", in: any) as? Int) == 3
    }

    func test_ShrubAny_set() throws {

        var any: Any? = 1
        try ShrubAny<String>.set([], in: &any, to: 2)
        hope(any as? Int) == 2

        any = ["one": 1]
        try ShrubAny.set("two", in: &any, to: 2)
        try hope(ShrubAny.get("two", in: any) as? Int) == 2

        any = [:]
        try ShrubAny.set("one", "two", "three", in: &any, to: 3)
        try hope(ShrubAny.get("one", "two", "three", in: any) as? Int) == 3

        any = 0
        try ShrubAny.set(2, "three", 4, "five", in: &any, to: "😃")
        try hope(ShrubAny.get(2, "three", 4, "five", in: any) as? String) == "😃"
    }
}
