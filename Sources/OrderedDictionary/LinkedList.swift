public class LinkedList<T> {
    public typealias Element = T
    
    public class Node {
        internal var value: T
        
        internal weak var owner: LinkedList?
        internal var next: Node?
        internal var previous: Node?
        
        internal init(_ value: T,
                      owner: LinkedList?)
        {
            self.value = value
            self.owner = owner
        }
    }
    
    public struct Index {
        public var node: Node?
        
        internal init(node: Node?)
        {
            self.node = node
        }
    }
    
    private var start: Node?
    private var last: Node?
    public private(set) var count: Int
    
    public init() {
        self.count = 0
    }
}

extension LinkedList.Index : Comparable {
    public static func == (a: LinkedList.Index,
                           b: LinkedList.Index) -> Bool
    {
        checkComparablePair(a, b)
        
        return a.node === b.node
    }
    
    public static func < (a: LinkedList.Index,
                          b: LinkedList.Index) -> Bool {
        checkComparablePair(a, b)
        
        if a.node === b.node {
            return false
        }
        
        var i = a.node
        
        while true {
            if i?.next === b.node {
                return true
            }
            
            if i == nil {
                return false
            }
            
            i = i?.next
        }
    }
    
    private static func checkComparablePair(_ a: LinkedList.Index, _ b: LinkedList.Index) {
        if let an = a.node, let bn = b.node {
            guard let aow = an.owner,
                let bow = bn.owner,
                aow === bow else
            {
                preconditionFailure("uncomparable index pair")
            }
        }
    }
}

extension LinkedList {
    private func node(_ value: Element) -> Node {
        return Node(value, owner: self)
    }
    
    public func append(_ element: Element) {
        insert(element, at: endIndex)
    }
    
    public func insert(_ element: Element, at index: Index) {
        checkValidIndex(index)
        
        if index == startIndex {
            insertAtStart(element)
            return
        }
        
        if index == endIndex {
            insertAtEnd(element)
            return
        }
        
        let newNode = node(element)
        
        let rightNode = index.node!
        let leftNode = rightNode.previous!
       
        leftNode.next = newNode
        newNode.previous = leftNode
        
        rightNode.previous = newNode
        newNode.next = rightNode
        
        count += 1
    }
    
    private func insertAtStart(_ element: Element) {
        let newNode = node(element)
        
        if let start = start {
            start.previous = newNode
            newNode.next = start
            self.start = newNode
        } else {
            start = newNode
            last = newNode
        }
        
        count += 1
    }
    
    private func insertAtEnd(_ element: Element) {
        let newNode = node(element)
        
        if let end = last {
            end.next = newNode
            newNode.previous = end
            self.last = newNode
        } else {
            start = newNode
            last = newNode
        }
        
        count += 1
    }

    @discardableResult
    public func remove(at index: Index) -> Element {
        checkValidIndex(index)
        
        // check endIndex
        let value = self[index]
        
        let targetNode = index.node!
        let leftNode = targetNode.previous
        let rightNode = targetNode.next
        targetNode.previous = nil
        targetNode.next = nil
        targetNode.owner = nil
        
        leftNode?.next = rightNode
        rightNode?.previous = leftNode
        
        if start === targetNode {
            self.start = rightNode
        }
        if last === targetNode {
            self.last = leftNode
        }
        
        count -= 1
        
        return value
    }

    public convenience init<S: Sequence>(_ s: S) where S.Element == Element {
        self.init()
        for x in s {
            self.append(x)
        }
    }
    
    public func copy() -> LinkedList<Element> {
        return LinkedList(self)
    }
}

extension LinkedList : Collection {
    public var startIndex: Index {
        return index(for: start)
    }
    
    public var endIndex: Index {
        return index(for: nil)
    }
    
    public subscript(position: Index) -> T {
        checkValidIndex(position)
        
        guard let node = position.node else {
            preconditionFailure("Index out of range")
        }
        return node.value
    }
    
    public func index(after i: Index) -> Index {
        checkValidIndex(i)
        
        guard let node = i.node else {
            preconditionFailure("Can't advance past endIndex")
        }
        
        return index(for: node.next)
    }
    
    private func index(for node: Node?) -> Index {
        return Index(node: node)
    }
    
    private func checkValidIndex(_ index: Index) {
        if let node = index.node {
            precondition(node.owner === self, "index for other LinkedList")
        }
    }
}

extension LinkedList : BidirectionalCollection {
    public func index(before i: Index) -> Index {
        checkValidIndex(i)
        
        let prevNode: Node?
        
        if let node = i.node {
            prevNode = node.previous
        } else {
            // index is end
            prevNode = self.last
        }
        
        if prevNode == nil {
            preconditionFailure("Can't advance before startIndex")
        }
        
        return index(for: prevNode)
    }
}
