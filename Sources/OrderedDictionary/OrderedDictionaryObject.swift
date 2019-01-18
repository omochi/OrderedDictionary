public class OrderedDictionaryObject<Key, Value> where Key : Hashable {
    public typealias Element = (key: Key, value: Value)
    
    internal typealias KeyList = LinkedListObject<Key>
    
    public struct Index {
        internal var keyListIndex: KeyList.Index
        
        internal init(keyListIndex: KeyList.Index)
        {
            self.keyListIndex = keyListIndex
        }
    }
    
    internal struct Entry {
        public var value: Value
        public var keyListIndex: KeyList.Index
        
        public init(value: Value,
                    keyListIndex: KeyList.Index)
        {
            self.value = value
            self.keyListIndex = keyListIndex
        }
    }
    
    internal var dictionary: Dictionary<Key, Entry>
    internal let keyList: KeyList
    
    public convenience init() {
        self.init(dictionary: Dictionary(),
                  keyList: KeyList())
    }
    
    internal init(dictionary: Dictionary<Key, Entry>,
                  keyList: KeyList)
    {
        self.dictionary = dictionary
        self.keyList = keyList
    }
}

internal enum _MergeError : Error {
    case keyCollision
}

extension OrderedDictionaryObject.Index : Comparable {
    public static func == (a: OrderedDictionaryObject.Index,
                           b: OrderedDictionaryObject.Index) -> Bool
    {
        return a.keyListIndex == b.keyListIndex
    }
    
    public static func < (a: OrderedDictionaryObject.Index,
                          b: OrderedDictionaryObject.Index) -> Bool
    {
        return a.keyListIndex < b.keyListIndex
    }
}

extension OrderedDictionaryObject {
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
    
    public convenience init(_ keyAndValues: KeyValuePairs<Key, Value>) {
        self.init()
        
        for (k, v) in keyAndValues {
            self[k] = v
        }
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
            
            insert(newValue, for: key, before: endKey)
        }
    }
    
    private func remove(for key: Key) {
        guard let entry = dictionary[key] else {
            return
        }
        
        dictionary[key] = nil
        keyList.remove(at: entry.keyListIndex)
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

    public func insert(_ value: Value, for key: Key, before rightKey: Key?) {
        remove(for: key)
        
        let rightKeyListIndex = self.keyListIndex(of: rightKey)
        _insert(value, for: key, before: rightKeyListIndex)
    }
    
    public func insert(_ value: Value, for key: Key, after leftKey: Key) {
        let rightKey = self.key(after: leftKey)
        
        insert(value, for: key, before: rightKey)
    }
    
    private func _insert(_ value: Value, for key: Key, before rightKeyListIndex: KeyList.Index) {
        let keyListIndex = keyList.insert(key, at: rightKeyListIndex)
        let entry = Entry(value: value, keyListIndex: keyListIndex)
        dictionary[key] = entry
    }
    
    public var startKey: Key? {
        return self.key(for: keyList.startIndex)
    }
    
    public var endKey: Key? {
        return self.key(for: keyList.endIndex)
    }
    
    public func key(after key: Key?) -> Key? {
        var keyListIndex = self.keyListIndex(of: key)
        keyListIndex = self.keyList.index(after: keyListIndex)
        return self.key(for: keyListIndex)
    }
    
    public func key(before key: Key?) -> Key? {
        var keyListIndex = self.keyListIndex(of: key)
        keyListIndex = self.keyList.index(before: keyListIndex)
        return self.key(for: keyListIndex)
    }
    
    public func copy(indices oldIndices: inout [Index]) -> OrderedDictionaryObject<Key, Value> {
        let newObject = OrderedDictionaryObject()
        for (k, v) in self {
            newObject[k] = v
        }
        
        var newIndices: [Index] = []
        for oldIndex in oldIndices {
            let oldKeyListIndex = self.keyListIndex(of: oldIndex)
            let key = self.key(for: oldKeyListIndex)
            let newKeyListIndex = newObject.keyListIndex(of: key)
            let newIndex = newObject.index(for: newKeyListIndex)
            newIndices.append(newIndex)
        }
        oldIndices = newIndices
        
        return newObject
    }
    
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> OrderedDictionaryObject<Key, T> {
        let c = OrderedDictionaryObject<Key, T>()
        for (k, v) in self {
            c[k] = try transform(v)
        }
        return c
    }
}

extension OrderedDictionaryObject : Collection {
    public subscript(position: Index) -> (key: Key, value: Value) {
        let keyListIndex = self.keyListIndex(of: position)
        guard let key = self.key(for: keyListIndex),
            let value = self[key] else
        {
            preconditionFailure("Index out of range")
        }
        return (key: key, value: value)
    }
    
    public var startIndex: Index {
        return self.index(for: keyList.startIndex)
    }
    
    public var endIndex: Index {
        return self.index(for: keyList.endIndex)
    }
    
    public var count: Int {
        return keyList.count
    }
    
    public func index(after i: Index) -> Index {
        var keyListIndex = self.keyListIndex(of: i)
        keyListIndex = keyList.index(after: keyListIndex)
        return self.index(for: keyListIndex)
    }
    
    public func index(before i: Index) -> Index {
        var keyListIndex = self.keyListIndex(of: i)
        keyListIndex = keyList.index(before: keyListIndex)
        return self.index(for: keyListIndex)
    }

    // Index <-> KeyList.Index

    private func keyListIndex(of index: Index) -> KeyList.Index {
        return index.keyListIndex
    }

    private func index(for keyListIndex: KeyList.Index) -> Index {
        return Index(keyListIndex: keyListIndex)
    }
    
    // Key? <-> KeyList.Index
    
    private func keyListIndex(of key: Key?) -> KeyList.Index {
        guard let key = key,
            let entry = dictionary[key] else
        {
            return keyList.endIndex
        }
        return entry.keyListIndex
    }
    
    private func key(for keyListIndex: KeyList.Index) -> Key? {
        if keyListIndex == keyList.endIndex {
            return nil
        }
        return keyList[keyListIndex]
    }
}

extension OrderedDictionaryObject : BidirectionalCollection {}

