import XCTest
import OrderedDictionary
import GameKit

class BenchmarkTests: XCTestCase {
    static var chars: String!
    static var random: GKRandomDistribution!
    static var dummyDataArray: Array<String>!
    static var dummyDataSet: Set<String>!
    
    static func makeRandomString() -> String {
        var r = ""
        for _ in 0..<8 {
            let i = random.nextInt()
            let index = chars.index(chars.startIndex, offsetBy: i)
            r.append(String(chars[index]))
        }
        return r
    }
    
    static func makeUniqueRandomString() -> String {
        while true {
            let str = makeRandomString()
            if dummyDataSet.contains(str) {
                continue
            }
            return str
        }
    }
    
    static override func setUp() {
        self.dummyDataArray = []
        self.dummyDataSet = Set()
        
        self.chars = "abcdefghijklmnopqrstuvwxyz" +
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        let randomSource = GKMersenneTwisterRandomSource()
        randomSource.seed = 456312482236
        
        self.random = GKRandomDistribution(randomSource: randomSource,
                                           lowestValue: 0,
                                           highestValue: chars.count - 1)
        
        for _ in 0..<(10000 * 100) {
            let str = makeUniqueRandomString()
            dummyDataArray.append(str)
            dummyDataSet.insert(str)
        }
    }
    
    static func dummyData(index: Int) -> String {
        return dummyDataArray[index]
    }
    
    func testRead_OrderedDictionary() {
        let rep = 100000
        // 0.017378
        testReadFromN_OrderedDictionary(n: 100, rep: rep)
        // 0.017562
        testReadFromN_OrderedDictionary(n: 1000, rep: rep)
        // 0.016162
        testReadFromN_OrderedDictionary(n: 10000, rep: rep)
    }
    
    func testRead_Dictionary() {
        let rep = 100000
        // 0.002091
        testReadFromN_Dictionary(n: 100, rep: rep)
        // 0.002274
        testReadFromN_Dictionary(n: 1000, rep: rep)
        // 0.002129
        testReadFromN_Dictionary(n: 10000, rep: rep)
    }
    
    func testRead_TupleArray() {
        let rep = 100000
        // 0.006816
        testReadFromN_TupleArray(n: 100, rep: rep)
        // 0.010593
        testReadFromN_TupleArray(n: 200, rep: rep)
        // 0.020438
        testReadFromN_TupleArray(n: 400, rep: rep)
        // 0.030018
        testReadFromN_TupleArray(n: 600, rep: rep)
        // 0.049432
        testReadFromN_TupleArray(n: 1000, rep: rep)
        // 0.523678
        testReadFromN_TupleArray(n: 10000, rep: rep)
    }
    
    func testInsert_OrderedDictionary() {
        let rep = 1000
        // 0.035498
        testInsertFromN_OrderedDictionary(n: 100, ins: 10, rep: rep)
        // 0.070154
        testInsertFromN_OrderedDictionary(n: 100, ins: 20, rep: rep)
        // 0.143495
        testInsertFromN_OrderedDictionary(n: 100, ins: 40, rep: rep)
        // 0.035459
        testInsertFromN_OrderedDictionary(n: 1000, ins: 10, rep: rep)
        // 0.071344
        testInsertFromN_OrderedDictionary(n: 1000, ins: 20, rep: rep)
        // 0.143642
        testInsertFromN_OrderedDictionary(n: 1000, ins: 40, rep: rep)
    }
    
    func testInsert_TupleArray() {
        let rep = 1000
        // 0.006978
        testInsertFromN_TupleArray(n: 1000, ins: 10, rep: rep)
        // 0.013356
        testInsertFromN_TupleArray(n: 1000, ins: 20, rep: rep)
        // 0.026330
        testInsertFromN_TupleArray(n: 1000, ins: 40, rep: rep)
        // 0.035451
        testInsertFromN_TupleArray(n: 5000, ins: 10, rep: rep)
        // 0.072914
        testInsertFromN_TupleArray(n: 5000, ins: 20, rep: rep)
        // 0.148221
        testInsertFromN_TupleArray(n: 5000, ins: 40, rep: rep)
        // 0.071285
        testInsertFromN_TupleArray(n: 10000, ins: 10, rep: rep)
        // 0.145145
        testInsertFromN_TupleArray(n: 10000, ins: 20, rep: rep)
        // 0.293951
        testInsertFromN_TupleArray(n: 10000, ins: 40, rep: rep)
    }
   
    private func testReadFromN_OrderedDictionary(n: Int, rep: Int) {
        var o = OrderedDictionary<String, String>()
        for i in 0..<n {
            let x = BenchmarkTests.dummyData(index: i)
            o[x] = x
        }
        
        myPerformanceTest { (measure) in
            let target = BenchmarkTests.dummyData(index: n/2)
            measure {
                for _ in 0..<rep {
                    _ = o[target]
                }
            }
        }
    }
    
    private func testReadFromN_Dictionary(n: Int, rep: Int) {
        var o = Dictionary<String, String>()
        for i in 0..<n {
            let x = BenchmarkTests.dummyData(index: i)
            o[x] = x
        }
        myPerformanceTest { (measure) in
            let target = BenchmarkTests.dummyData(index: n/2)
            measure {
                for _ in 0..<rep {
                    _ = o[target]
                }
            }
        }
    }
    
    private func testReadFromN_TupleArray(n: Int, rep: Int) {
        var o = Array<(String, String)>()
        for i in 0..<n {
            let x = BenchmarkTests.dummyData(index: i)
            o.append((x, x))
        }
        myPerformanceTest { (measure) in
            let target = BenchmarkTests.dummyData(index: n/2)
            measure {
                for _ in 0..<rep {
                    let index = o.firstIndex { (k, v) in k == target }!
                    _ = o[index]
                }
            }
        }
    }
    
    private func testInsertFromN_OrderedDictionary(n: Int, ins: Int, rep: Int) {
        var o0 = OrderedDictionary<String, String>()
        for i in 0..<n {
            let x = BenchmarkTests.dummyData(index: i)
            o0[x] = x
        }

        myPerformanceTest { (measure) in
            for _ in 0..<rep {
                var o = o0.mapValues { $0 }
                measure {
                    for i in 0..<ins {
                        let targetIndex = n * i / ins
                        let target = BenchmarkTests.dummyData(index: targetIndex)
                        let nv = BenchmarkTests.dummyData(index: n + i)
                        o.insert(nv, for: nv, after: target)
                    }
                }
            }
        }
    }
    
    private func testInsertFromN_TupleArray(n: Int, ins: Int, rep: Int) {
        var o0 = Array<(String, String)>()
        for i in 0..<n {
            let x = BenchmarkTests.dummyData(index: i)
            o0.append((x, x))
        }
        
        myPerformanceTest { (measure) in
            for _ in 0..<rep {
                var o = o0.map { $0 }
                measure {
                    for i in 0..<ins {
                        let targetIndex = n * i / ins
                        let target = BenchmarkTests.dummyData(index: targetIndex)
                        let nv = BenchmarkTests.dummyData(index: n + i)
                        let index = (o.firstIndex { $0.0 == target })!
                        o.insert((nv, nv), at: index + 1)
                    }
                }
            }
        }
    }
    
    typealias TaskFunc = () -> Void
    typealias MeasureFunc = (TaskFunc) -> Void
    
    private func myPerformanceTest(_ body: (MeasureFunc) -> Void) {
        var time: UInt64 = 0
        func measure(task: TaskFunc) {
            let start = DispatchTime.now()
            task()
            let end = DispatchTime.now()
            let interval = end.uptimeNanoseconds - start.uptimeNanoseconds
            time += interval
        }
        body(measure)
        let sec = Double(time) / 1000000000
        print(String(format: "%0.6f", sec))
    }
}
