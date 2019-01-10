import Foundation

public struct OrderedDictionary<Key, Value> where Key : Hashable {
    public typealias Element = (key: Key, value: Value)
    public typealias Index = OrderedDictionaryObject<Key, Value>.Index
    public typealias Object = OrderedDictionaryObject<Key, Value>
    
    public var object: Object
    
    public init() {
        self.init(object: Object())
    }
    
    public init(object: Object) {
        self.object = object
    }
}

extension OrderedDictionary {
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
    
    public init<S>(uniqueKeysWithValues keysAndValues: S)
        where S : Sequence, S.Element == (Key, Value)
    {
        let object = Object(uniqueKeysWithValues: keysAndValues)
        self.init(object: object)
    }
    
    public init<S>(_ keysAndValues: S,
                   uniquingKeysWith combine: (Value, Value) throws -> Value)
        rethrows where S : Sequence, S.Element == (Key, Value)
    {
        let object = try Object(keysAndValues, uniquingKeysWith: combine)
        self.init(object: object)
    }
    
    public var keys: [Key] {
        return object.keys
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return object[key]
        }
        set {
            copyIfNeed()
            object[key] = newValue
        }
    }
    
    public mutating func merge<S>(_ other: S,
                         uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        where S : Sequence, S.Element == (Key, Value)
    {
        copyIfNeed()
        try object.merge(other, uniquingKeysWith: combine)
    }
    
    public mutating func insert(_ value: Value, for key: Key, before rightKey: Key?) {
        copyIfNeed()
        object.insert(value, for: key, before: rightKey)
    }
    
    public mutating func insert(_ value: Value, for key: Key, after leftKey: Key) {
        copyIfNeed()
        object.insert(value, for: key, after: leftKey)
    }
    
    public var startKey: Key? {
        return object.startKey
    }
    
    public var endKey: Key? {
        return object.endKey
    }
    
    public func key(after key: Key?) -> Key? {
        return object.key(after: key)
    }
    
    public func key(before key: Key?) -> Key? {
        return object.key(before: key)
    }
}

extension OrderedDictionary : Collection {
    public subscript(position: Index) -> (key: Key, value: Value) {
        return object[position]
    }
    
    public var startIndex: Index {
        return object.startIndex
    }
    
    public var endIndex: Index {
        return object.endIndex
    }
    
    public var count: Int {
        return object.count
    }
    
    public func index(after i: Index) -> Index {
        return object.index(after: i)
    }
    
    public func index(before i: Index) -> Index {
        return object.index(before: i)
    }
}

extension OrderedDictionary : BidirectionalCollection {}
