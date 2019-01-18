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
    
    public init(_ keyAndValues: KeyValuePairs<Key, Value>) {
        let object = Object(keyAndValues)
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
        
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> OrderedDictionary<Key, T> {
        return OrderedDictionary<Key, T>(object: try object.mapValues(transform))
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

extension OrderedDictionary {
    public struct StringCodingKey : CodingKey {
        public var stringValue: String

        public init(_ value: String) {
            self.stringValue = value
        }
        
        public init(stringValue: String) {
            self.init(stringValue)
        }
        
        public var intValue: Int? { return nil }
        public init?(intValue: Int) { return nil }
    }
}

extension OrderedDictionary : Decodable where Key == String, Value : Decodable {
    public init(from decoder: Decoder) throws {
        self.init()
        
        let c = try decoder.container(keyedBy: StringCodingKey.self)
        let keys = c.allKeys
        for key in keys {
            let value = try c.decode(Value.self, forKey: key)
            self[key.stringValue] = value
        }
    }
}

extension OrderedDictionary : Encodable where Key == String, Value : Encodable {
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: StringCodingKey.self)
        for (key, value) in self {
            try c.encode(value, forKey: StringCodingKey(key))
        }
    }
}

extension OrderedDictionary : Equatable where Key : Equatable, Value : Equatable {
    public static func == (a: OrderedDictionary<Key, Value>, b: OrderedDictionary<Key, Value>) -> Bool {
        guard a.count == b.count else {
            return false
        }
        
        var ia = a.startIndex
        var ib = b.startIndex
        while ia != a.endIndex {
            let (ak, av) = a[ia]
            let (bk, bv) = b[ib]
            
            guard ak == bk && av == bv else {
                return false
            }
            
            ia = a.index(after: ia)
            ib = b.index(after: ib)
        }
        precondition(ib == b.endIndex)
        
        return true
    }
}

extension OrderedDictionary : Hashable where Key : Hashable, Value : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(count)
        
        for (k, v) in self {
            hasher.combine(k)
            hasher.combine(v)
        }
    }
}
