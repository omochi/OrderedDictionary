public class LinkedListObject<T> {
    public typealias Element = T
    
    internal class Node {
        internal var value: T
        
        internal weak var owner: LinkedListObject?
        internal var next: Node?
        internal var previous: Node?
        
        internal init(_ value: T,
                      owner: LinkedListObject?)
        {
            self.value = value
            self.owner = owner
        }
    }
    
    public struct Index {
        internal var node: Node?
        
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

extension LinkedListObject.Index : Comparable {
    public static func == (a: LinkedListObject.Index,
                           b: LinkedListObject.Index) -> Bool
    {
        checkComparablePair(a, b)
        
        return a.node === b.node
    }
    
    public static func < (a: LinkedListObject.Index,
                          b: LinkedListObject.Index) -> Bool {
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
    
    private static func checkComparablePair(_ a: LinkedListObject.Index, _ b: LinkedListObject.Index) {
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

extension LinkedListObject {
    private func node(_ value: Element) -> Node {
        return Node(value, owner: self)
    }
    
    @discardableResult
    public func append(_ element: Element) -> Index {
        return insert(element, at: endIndex)
    }
    
    @discardableResult
    public func insert(_ element: Element, at index: Index) -> Index {
        checkValidIndex(index)
        
        if index == startIndex {
            return insertAtStart(element)
        }
        
        if index == endIndex {
            return insertAtEnd(element)
        }
        
        let newNode = node(element)
        
        let rightNode = index.node!
        let leftNode = rightNode.previous!
       
        leftNode.next = newNode
        newNode.previous = leftNode
        
        rightNode.previous = newNode
        newNode.next = rightNode
        
        count += 1
        
        return self.index(for: newNode)
    }

    private func insertAtStart(_ element: Element) -> Index {
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
        
        return index(for: newNode)
    }
    
    private func insertAtEnd(_ element: Element) -> Index {
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
        
        return index(for: newNode)
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

    public func copy(indices oldIndices: inout [Index]) -> LinkedListObject<Element> {
        var newIndices: [Index?] = Array(repeating: nil, count: oldIndices.count)
        
        func convertIndex(_ oldIndex: Index, to newIndex: Index) {
            for (i, iterIndex) in oldIndices.enumerated() {
                if iterIndex == oldIndex {
                    newIndices[i] = newIndex
                }
            }
        }
        
        let newObject = LinkedListObject<Element>()
        
        var oldIndex = startIndex
        while oldIndex != endIndex {
            let element = self[oldIndex]
            
            let newIndex = newObject.append(element)
            
            convertIndex(oldIndex, to: newIndex)
            
            oldIndex = self.index(after: oldIndex)
        }
        
        convertIndex(self.endIndex, to: newObject.endIndex)
        
        if newIndices.contains(nil) {
            preconditionFailure("invalid indices passed")
        }
        
        oldIndices = newIndices.compactMap { $0 }
        return newObject
    }
}

extension LinkedListObject : Collection {
    public var startIndex: Index {
        return index(for: start)
    }
    
    public var endIndex: Index {
        return index(for: nil)
    }
    
    public subscript(position: Index) -> T {
        get {
            checkValidIndex(position)
            
            guard let node = position.node else {
                preconditionFailure("Index out of range")
            }
            return node.value
        }
        set {
            checkValidIndex(position)
            
            guard let node = position.node else {
                preconditionFailure("Index out of range")
            }
            
            node.value = newValue
        }
    }
    
    public func index(after i: Index) -> Index {
        checkValidIndex(i)
        
        guard let node = i.node else {
            preconditionFailure("Can't advance past endIndex")
        }
        
        return index(for: node.next)
    }
    
    private func index(for node: Node?) -> Index {
        if let node = node {
            precondition(node.owner === self, "invalid node")
        }
        return Index(node: node)
    }
    
    private func checkValidIndex(_ index: Index) {
        if let node = index.node {
            precondition(node.owner === self, "index for other LinkedList")
        }
    }
}

extension LinkedListObject : BidirectionalCollection {
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

extension LinkedListObject : MutableCollection {}
