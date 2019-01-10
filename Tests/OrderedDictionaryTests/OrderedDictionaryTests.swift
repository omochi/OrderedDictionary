import XCTest

import OrderedDictionary

class OrderedDictionaryTests: XCTestCase {
    func testSubscript() {
        var a = OrderedDictionary<String, Int>()
        assert(a, [])
        
        a["a"] = 1
        assert(a, [("a", 1)])
        
        a["b"] = 2
        assert(a, [("a", 1), ("b", 2)])

        let b = a
        
        a["c"] = 3
        assert(a, [("a", 1), ("b", 2), ("c", 3)])
        assert(b, [("a", 1), ("b", 2)])
        
        a["a"] = 4
        assert(a, [("a", 4), ("b", 2), ("c", 3)])
        
        let c = a
        
        a["b"] = nil
        assert(a, [("a", 4), ("c", 3)])
        assert(c, [("a", 4), ("b", 2), ("c", 3)])
        
        a["c"] = nil
        assert(a, [("a", 4)])
        
        a["a"] = nil
        assert(a, [])
        
        a["b"] = 5
        assert(a, [("b", 5)])
    }
    
    func testEdit() {
        var a = OrderedDictionary<String, Int>()
        assert(a, [])
        
        a["b"] = 1
        a["c"] = 2
        a["f"] = 3
        assert(a, [("b", 1), ("c", 2), ("f", 3)])
        
        let b = a
        
        a.insert(4, for: "d", before: "f")
        assert(a, [("b", 1), ("c", 2), ("d", 4), ("f", 3)])
        assert(b, [("b", 1), ("c", 2), ("f", 3)])
        
        a.insert(5, for: "e", after: "d")
        assert(a, [("b", 1), ("c", 2), ("d", 4), ("e", 5), ("f", 3)])
        
        a.insert(6, for: "g", before: nil)
        assert(a, [("b", 1), ("c", 2), ("d", 4), ("e", 5), ("f", 3), ("g", 6)])
        
        let c = a
        
        a["b"] = nil
        assert(a, [("c", 2), ("d", 4), ("e", 5), ("f", 3), ("g", 6)])
        assert(c, [("b", 1), ("c", 2), ("d", 4), ("e", 5), ("f", 3), ("g", 6)])
        
        a["g"] = nil
        assert(a, [("c", 2), ("d", 4), ("e", 5), ("f", 3)])
        
        a["d"] = nil
        assert(a, [("c", 2), ("e", 5), ("f", 3)])
        
        a["c"] = 7
        assert(a, [("c", 7), ("e", 5), ("f", 3)])
        
        a.insert(8, for: "c", after: "e")
        assert(a, [("e", 5), ("c", 8), ("f", 3)])
    }
    
    private func keysByIteration<T>(_ dict: OrderedDictionary<String, T>) -> [String] {
        var ret: [String] = []
        var k = dict.startKey
        while k != dict.endKey {
            ret.append(k!)
            k = dict.key(after: k)
        }
        return ret
    }
    private func reverseKeysByIteration<T>(_ dict: OrderedDictionary<String, T>) -> [String] {
        var ret: [String] = []
        var k = dict.endKey
        while true {
            if let k = k {
                ret.append(k)
            }
            if k == dict.startKey {
                break
            }
            k = dict.key(before: k)
        }
        return ret
    }
    
    private func assert<T>(_ dict: OrderedDictionary<String, T>,
                           _ expected: [(String, T)],
                           file: StaticString = #file,
                           line: UInt = #line)
        where T: Equatable
    {
        let actual: [KV<String, T>] = Array(dict).map { KV($0, $1) }
        let expected: [KV<String, T>] = expected.map { KV($0, $1) }
        XCTAssertEqual(actual, expected, file: file, line: line)
        
        let actualRev = Array(dict.reversed()).map { KV($0, $1) }
        XCTAssertEqual(actualRev, expected.reversed(), file: file, line: line)
        
        let actualIterKeys = keysByIteration(dict)
        XCTAssertEqual(actualIterKeys, expected.map { $0.k }, file: file, line: line)
        
        let actualRevIterKeys = reverseKeysByIteration(dict)
        XCTAssertEqual(actualRevIterKeys, expected.reversed().map { $0.k }, file: file, line: line)
        
        let actualPropKeys = dict.keys
        XCTAssertEqual(actualPropKeys, expected.map { $0.k })
    }
}
