import XCTest

import OrderedDictionary

internal struct KV<K, V> {
    public var k: K
    public var v: V
    
    public init(_ k: K, _ v: V) {
        self.k = k
        self.v = v
    }
}

extension KV : Equatable where K : Equatable, V : Equatable {}

class OrderedDictionaryObjectTests: XCTestCase {
    func testSubscript() {
        let a = OrderedDictionaryObject<String, Int>()
        XCTAssertEqual(a.count, 0)
        assert(a, [])
        
        a["a"] = 1
        XCTAssertEqual(a.count, 1)
        assert(a, [("a", 1)])
        
        a["b"] = 2
        XCTAssertEqual(a.count, 2)
        assert(a, [("a", 1), ("b", 2)])
        
        a["c"] = 3
        assert(a, [("a", 1), ("b", 2), ("c", 3)])
        
        a["a"] = 4
        assert(a, [("a", 4), ("b", 2), ("c", 3)])
        
        a["b"] = nil
        assert(a, [("a", 4), ("c", 3)])
        
        a["c"] = nil
        assert(a, [("a", 4)])
        
        a["a"] = nil
        assert(a, [])
        
        a["b"] = 5
        assert(a, [("b", 5)])
    }

    private func assert<T>(_ dict: OrderedDictionaryObject<String, T>,
                           _ expected: [(String, T)],
                           file: StaticString = #file,
                           line: UInt = #line)
        where T: Equatable
    {
        let actual: [KV<String, T>] = Array(dict).map { KV($0, $1) }
        let expected: [KV<String, T>] = expected.map { KV($0, $1) }
        
        XCTAssertEqual(actual, expected, file: file, line: line)
        
        let revActual = Array(dict.reversed()).map { KV($0, $1) }

        XCTAssertEqual(revActual, expected.reversed(), file: file, line: line)
    }
}
