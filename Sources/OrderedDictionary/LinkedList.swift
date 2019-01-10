public struct LinkedList<T> {
    public typealias Element = T
    public typealias Index = LinkedListObject<Element>.Index
    
    public var object: LinkedListObject<Element>
    
    public init() {
        self.init(object: LinkedListObject<Element>())
    }
    
    public init(object: LinkedListObject<Element>) {
        self.object = object
    }
}

extension LinkedList {
    private mutating func copyIfNeed(indices: inout [Index]) {
        if !isKnownUniquelyReferenced(&object) {
            self.object = object.copy(indices: &indices)
        }
    }
    
    private mutating func copyIfNeed() {
        var ixs: [Index] = []
        copyIfNeed(indices: &ixs)
    }
    
    private mutating func copyIfNeed(indices i0: inout Index) {
        var ixs: [Index] = [i0]
        copyIfNeed(indices: &ixs)
        i0 = ixs[0]
    }
    
    private mutating func copyIfNeed(indices i0: inout Index, _ i1: inout Index) {
        var ixs: [Index] = [i0, i1]
        copyIfNeed(indices: &ixs)
        i0 = ixs[0]
        i1 = ixs[1]
    }
    
    @discardableResult
    public mutating func append(_ element: Element) -> Index {
        return insert(element, at: endIndex)
    }
    
    @discardableResult
    public mutating func insert(_ element: Element, at index: Index) -> Index {
        var index = index
        copyIfNeed(indices: &index)
        return object.insert(element, at: index)
    }
    
    @discardableResult
    public mutating func remove(at index: Index) -> Element {
        var index = index
        copyIfNeed(indices: &index)
        return object.remove(at: index)
    }
    
    public init<S: Sequence>(_ s: S) where S.Element == Element {
        self.init()
        for x in s {
            self.append(x)
        }
    }
}

extension LinkedList : Collection {
    public var startIndex: Index {
        return object.startIndex
    }
    
    public var endIndex: Index {
        return object.endIndex
    }
    
    public subscript(position: Index) -> Element {
        get {
            return object[position]
        }
        set {
            var position = position
            copyIfNeed(indices: &position)
            object[position] = newValue
        }
    }
    
    public func index(after i: Index) -> Index {
        return object.index(after: i)
    }
    
    public func index(before i: Index) -> Index {
        return object.index(before: i)
    }
}

extension LinkedList : BidirectionalCollection {}
extension LinkedList : MutableCollection {}

extension LinkedList : Decodable where Element : Decodable {
    public init(from decoder: Decoder) throws {
        self.init()
        
        var c = try decoder.unkeyedContainer()
        while !c.isAtEnd {
            let e = try c.decode(Element.self)
            self.append(e)
        }
    }
}

extension LinkedList : Encodable where Element : Encodable {
    public func encode(to encoder: Encoder) throws {
        var c = encoder.unkeyedContainer()
        for e in self {
            try c.encode(e)
        }
    }
}
