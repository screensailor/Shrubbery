@_exported import Hope
@_exported import Peek
@_exported import Shrubbery
@_exported import Combine

private extension Forks where Key == String {
    var a: Forks { __("a") }
    var b: Forks { __("b") }
    var c: Forks { __("c") }
}

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
        hope.true(isNilAfterFlattening(o["one"].unwrapped)) // none left
        
        o["one", "two"] = nil
        hope.true(isNilAfterFlattening(o["one", "two"].unwrapped))
    }
    
    func test_subscript_with_dedicated_keys() throws {
        
        enum K { case a, b, c }
        
        var o: Shrub<K> = nil
        
        o[.a] = "a"
        hope(o[.a]) == "a"
        
        o[^.a, ^2, ^.c] = "c"
        hope(o[^.a, ^2, ^.c]) == "c"
    }
    
    func test_subscript_with_I() throws {
        
        let my: Forks<JSON.Key> = []
        
        var o: JSON = nil
        
        o[my.a] = "a"
        hope(o[my.a]) == "a"
        
        o[my.a.b.c] = "abc"
        hope(o[my.a.b.c]) == "abc"
        
        o[my.a.2.c] = "a2c"
        hope(o[my.a.2.c]) == "a2c"
    }

    func test_expressible() throws {
        
        let o: JSON = [
            "one": [
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

    func test_Shrub_get() throws {

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

    func test_Shrub_set() throws {

        var any: Any? = 1
        JSON.set([], in: &any, to: 2)
        hope(any as? Int) == 2

        any = ["one": 1]
        JSON.set("two", in: &any, to: 2)
        try hope(JSON.get("two", in: any) as? Int) == 2

        any = [:]
        JSON.set("one", "two", "three", in: &any, to: 3)
        try hope(JSON.get("one", "two", "three", in: any) as? Int) == 3

        any = 0
        JSON.set(2, "three", 4, "five", in: &any, to: "😃")
        try hope(JSON.get(2, "three", 4, "five", in: any) as? String) == "😃"
    }

    func test_merge() throws {

        var a: JSON = [
            "one": [
                "two": [
                    1, 2
                ],
                "four": [
                    "x": [
                        "y": [
                            "z": "Ω"
                        ]
                    ]
                ]
            ],
            "and": ["so", "on", "..."]
        ]

        let b: JSON = [
            "one": [
                "two": 2,
                "three": "👋",
                "four": [
                    "x": [
                        "y": [
                            "z": "Z",
                            "zzz": "😴"
                        ]
                    ]
                ]
            ],
            "and": [
                "so": "forth..."
            ]
        ]

        a.merge(b)

        hope(a.debugDescription) == JSON([
            "one": [
                "two": 2,
                "three": "👋",
                "four": [
                    "x": [
                        "y": [
                            "z": "Z",
                            "zzz": "😴"
                        ]
                    ]
                ]
            ],
            "and": [
                "so": "forth..."
            ]
        ]).debugDescription
    }

    func test_traverse_and_debugDescription() throws {
            
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
            json1.set(route, to: i)
        }
        
        // debugPrint(json1)

        measure {
            do {
                try json1.traverse { route, value in
                    guard case .leaf = value else { return }
                    let o = try json1.get(route)
                    json2.set(route, to: o)
                }
            } catch {
                hope.less("\(error)")
            }
        }
        
        hope(json1.debugDescription) == json2.debugDescription

        json1.merge(json2)

        hope(json1.debugDescription) == json2.debugDescription
    }
}
