public class OrderedDictionary<Key, Value> where Key : Hashable {
    public typealias Element = (key: Key, value: Value)
    
    public typealias Index = LinkedList<Key>.Index
    
    internal struct Entry {
        public var value: Value
        public var index: Index
        
        public init(value: Value,
                    index: Index)
        {
            self.value = value
            self.index = index
        }
    }

    internal var dictionary: Dictionary<Key, Entry>
    internal let keyList: LinkedList<Key>
    
    public init() {
        self.dictionary = [:]
        self.keyList = LinkedList()
    }
}

internal enum _MergeError : Error {
    case keyCollision
}

extension OrderedDictionary {
    public convenience init<S>(uniqueKeysWithValues keysAndValues: S)
        where S : Sequence, S.Element == (Key, Value)
    {
        self.init()
        
        try! merge(keysAndValues,
            uniquingKeysWith: { _, _ in throw _MergeError.keyCollision })
    }
    
    public convenience init<S>(_ keysAndValues: S,
        uniquingKeysWith combine: (Value, Value) throws -> Value)
        rethrows where S : Sequence, S.Element == (Key, Value)
    {
        self.init()
        try merge(keysAndValues, uniquingKeysWith: combine)
    }
    
    public var keys: [Key] {
        return keyList.map { $0 }
    }

    public subscript(key: Key) -> Value? {
        get {
            guard let entry = dictionary[key] else {
                return nil
            }
            return entry.value
        }
        set {
            guard let newValue = newValue else {
                remove(for: key)
                return
            }
            
            if var entry = dictionary[key] {
                entry.value = newValue
                dictionary[key] = entry
                return
            }
            
            insertAtEnd(newValue, key: key)
        }
    }
    
    private func remove(for key: Key) {
        guard let entry = dictionary[key] else {
            return
        }
        
        dictionary[key] = nil
        keyList.remove(at: entry.index)
    }

    public func merge<S>(_ other: S,
                         uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        where S : Sequence, S.Element == (Key, Value)
    {
        for (k, ov) in other {
            let v: Value
            if let sv = self[k] {
                v = try combine(sv, ov)
            } else {
                v = ov
            }
            self[k] = v
        }
    }
    
    public func key(at index: Index) -> Key {
        return keyList[index]
    }
    
    public func insertAtStart(_ value: Value, key: Key) {
        remove(for: key)
        _insert(value, key: key, at: keyList.startIndex)
    }
    
    public func insertAtEnd(_ value: Value, key: Key) {
        remove(for: key)
        _insert(value, key: key, at: keyList.endIndex)
    }
    
    public func insert(_ value: Value, key: Key, before rightKey: Key) {
        remove(for: key)
        
        guard let rightKeyEntry = dictionary[rightKey] else {
            preconditionFailure("key not found")
        }
        
        _insert(value, key: key, at: rightKeyEntry.index)
    }
    
    public func insert(_ value: Value, key: Key, after leftKey: Key) {
        remove(for: key)
        
        guard let leftKeyEntry = dictionary[leftKey] else {
            preconditionFailure("key not found")
        }
        
        _insert(value, key: key, at: keyList.index(after: leftKeyEntry.index))
    }
    
    private func _insert(_ value: Value, key: Key, at index: Index) {
        keyList.insert(key, at: index)
        
        let entry = Entry(value: value,
                          index: keyList.index(before: index))
        dictionary[key] = entry
    }
    
    public func copy() -> OrderedDictionary<Key, Value> {
        return OrderedDictionary(uniqueKeysWithValues: map { ($0, $1) })
    }
}

extension OrderedDictionary : Collection {
    public subscript(position: Index) -> (key: Key, value: Value) {
        let key = keyList[position]
        let value = self[key]!
        return (key, value)
    }
    
    public var startIndex: Index {
        return keyList.startIndex
    }
    
    public var endIndex: Index {
        return keyList.endIndex
    }
    
    public func index(after i: Index) -> Index {
        return keyList.index(after: i)
    }
    
    public var count: Int {
        return keyList.count
    }
}

extension OrderedDictionary : BidirectionalCollection {
    public func index(before i: Index) -> Index {
        return keyList.index(before: i)
    }
}

