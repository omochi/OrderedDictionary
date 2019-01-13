import XCTest
import OrderedDictionary

class LinkedListObjectTests: XCTestCase {
    func testAppend() {
        let a = LinkedListObject<Int>()
        assert(a, [])

        a.append(1)
        assert(a, [1])
        
        a.append(2)
        assert(a, [1, 2])
        
        a.append(3)
        assert(a, [1, 2, 3])
    }
    
    func testInsert() {
        let a = LinkedListObject<Int>()
        
        a.insert(1, at: a.startIndex)
        assert(a, [1])
        
        a.insert(2, at: a.startIndex)
        assert(a, [2, 1])
        
        a.insert(3, at: a.index(after: a.startIndex))
        assert(a, [2, 3, 1])
        
        a.insert(4, at: a.endIndex)
        assert(a, [2, 3, 1, 4])
        
        a.insert(5, at: a.index(before: a.endIndex))
        assert(a, [2, 3, 1, 5, 4])
        
        a.insert(6, at: a.index(after: a.index(after: a.startIndex)))
        assert(a, [2, 3, 6, 1, 5, 4])
    }
    
    func testRemove() {
        let a = LinkedListObject<Int>([1, 2, 3, 4])
        
        a.remove(at: a.startIndex)
        assert(a, [2, 3, 4])
        
        a.remove(at: a.index(after: a.startIndex))
        assert(a, [2, 4])
        
        a.remove(at: a.index(before: a.endIndex))
        assert(a, [2])
        
        a.remove(at: a.startIndex)
        assert(a, [])
        
        a.append(5)
        assert(a, [5])
    }
    
    func testSubscript() {
        let a = LinkedListObject<Int>([1, 2, 3, 4])
        
        a[a.startIndex] = 5
        assert(a, [5, 2, 3, 4])
        
        a[a.index(after: a.startIndex)] = 6
        assert(a, [5, 6, 3, 4])
        
        a[a.index(before: a.endIndex)] = 7
        assert(a, [5, 6, 3, 7])
    }
    
    private func assert<T>(_ list: LinkedListObject<T>,
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
    
    class Obj {
        static var count: Int = 0
        
        init() {
            Obj.count += 1
        }
        
        deinit {
            Obj.count -= 1
        }
    }
    
    func testLeak() {
        do {
            let a = LinkedListObject<Obj>()
            
            a.append(Obj())
            a.append(Obj())
            
            XCTAssertEqual(Obj.count, 2)            
        }
        
        XCTAssertEqual(Obj.count, 0)
    }
}
