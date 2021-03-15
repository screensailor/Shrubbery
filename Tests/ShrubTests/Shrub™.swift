@_exported import Hope
@_exported import Peek
@_exported import Shrub
@_exported import Combine

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
        try hope(JSON.get([], in: any) as? Int) == 1
        hope.throws(try JSON.get("one", in: any))

        any = ["one": 1]
        try hope(JSON.get("one", in: any) as? Int) == 1
        hope.throws(try JSON.get("two", in: any))

        any = ["one": ["two": ["three": 3]]]
        try hope(JSON.get("one", "two", "three", in: any) as? Int) == 3

        any = [any, any, any]
        try hope(JSON.get(1, "one", "two", "three", in: any) as? Int) == 3
    }

    func test_ShrubAny_set() throws {

        var any: Any? = 1
        try JSON.set([], in: &any, to: 2)
        hope(any as? Int) == 2

        any = ["one": 1]
        try JSON.set("two", in: &any, to: 2)
        try hope(JSON.get("two", in: any) as? Int) == 2

        any = [:]
        try JSON.set("one", "two", "three", in: &any, to: 3)
        try hope(JSON.get("one", "two", "three", in: any) as? Int) == 3

        any = 0
        try JSON.set(2, "three", 4, "five", in: &any, to: "😃")
        try hope(JSON.get(2, "three", 4, "five", in: any) as? String) == "😃"
    }
    
    func test_debugDescription() throws {
            
        let routes = JSON.Fork.randomRoutes(
            count: 1000,
            in: Array(0...2),
            and: "abc".map(String.init),
            bias: 0.1,
            length: 5...7,
            seed: 502645 // Int.random(in: 1000...1_000_000).peek("✅")
        )
        
        var json1: JSON = nil
        var json2: JSON = nil
        
        for (i, route) in routes.enumerated() {
            try json1.set(route, to: i)
        }
        
        // debugPrint(json1)

        measure {
            do {
                try json1.traverse { route, value in
                    guard case .leaf = value else { return }
                    let o = try json1.get(route)
                    try json2.set(route, to: o)
                }
            } catch {
                hope.less("\(error)")
            }
        }
        
        hope(json2.debugDescription) == json1.debugDescription
    }
}
