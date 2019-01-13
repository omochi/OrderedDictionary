import XCTest

import OrderedDictionary

class LinkedListTests: XCTestCase {
    func testAppend() {
        var a = LinkedList<Int>()
        assert(a, [])
        
        a.append(1)
        assert(a, [1])
        
        let b = a
        
        a.append(2)
        assert(a, [1, 2])
        assert(b, [1])
        
        a.append(3)
        assert(a, [1, 2, 3])
    }
    
    func testInsert() {
        var a = LinkedList<Int>()
        
        a.insert(1, at: a.startIndex)
        assert(a, [1])
        
        a.insert(2, at: a.startIndex)
        assert(a, [2, 1])
        
        a.insert(3, at: a.index(after: a.startIndex))
        assert(a, [2, 3, 1])
        
        let b = a
        
        a.insert(4, at: a.endIndex)
        assert(a, [2, 3, 1, 4])
        assert(b, [2, 3, 1])
        
        a.insert(5, at: a.index(before: a.endIndex))
        assert(a, [2, 3, 1, 5, 4])
        
        a.insert(6, at: a.index(after: a.index(after: a.startIndex)))
        assert(a, [2, 3, 6, 1, 5, 4])
    }
    
    func testRemove() {
        var a = LinkedList<Int>([1, 2, 3, 4])
        
        a.remove(at: a.startIndex)
        assert(a, [2, 3, 4])
        
        a.remove(at: a.index(after: a.startIndex))
        assert(a, [2, 4])
        
        let b = a
        
        a.remove(at: a.index(before: a.endIndex))
        assert(a, [2])
        assert(b, [2, 4])
        
        a.remove(at: a.startIndex)
        assert(a, [])
        
        a.append(5)
        assert(a, [5])
    }
    
    func testSubscript() {
        var a = LinkedList<Int>([1, 2, 3, 4])
        
        a[a.startIndex] = 5
        assert(a, [5, 2, 3, 4])
        
        a[a.index(after: a.startIndex)] = 6
        assert(a, [5, 6, 3, 4])
        
        let b = a
        
        a[a.index(before: a.endIndex)] = 7
        assert(a, [5, 6, 3, 7])
        assert(b, [5, 6, 3, 4])
    }
    
    private func assert<T>(_ list: LinkedList<T>,
                           _ expected: [T],
                           file: StaticString = #file,
                           line: UInt = #line)
        where T: Equatable
    {
        let actual = Array(list)
        
        XCTAssertEqual(actual, expected, file: file, line: line)
        
        let revActual = Array(list.reversed())
        
        XCTAssertEqual(revActual, expected.reversed(), file: file, line: line)
    }
}
