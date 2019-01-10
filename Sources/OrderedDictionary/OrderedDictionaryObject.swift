public class OrderedDictionaryObject<Key, Value> where Key : Hashable {
    public typealias Element = (key: Key, value: Value)
    
    public struct Index {
        public weak var owner: OrderedDictionaryObject?
        public var key: Key?
        
        public init(owner: OrderedDictionaryObject,
                    key: Key?)
        {
            self.owner = owner
            self.key = key
        }
    }
    
    internal typealias KeyList = LinkedListObject<Key>
    
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
    
    public init() {
        self.dictionary = [:]
        self.keyList = KeyList()
    }
}

internal enum _MergeError : Error {
    case keyCollision
}

extension OrderedDictionaryObject.Index : Comparable {
    public static func == (a: OrderedDictionaryObject.Index,
                           b: OrderedDictionaryObject.Index) -> Bool
    {
        checkComparablePair(a, b)
        return a.key == b.key
    }
    
    public static func < (a: OrderedDictionaryObject.Index,
                          b: OrderedDictionaryObject.Index) -> Bool
    {
        checkComparablePair(a, b)
        let akli = a.owner!.keyListIndex(for: a)
        let bkli = b.owner!.keyListIndex(for: b)
        return akli < bkli
    }
    
    private static func checkComparablePair(_ a: OrderedDictionaryObject.Index,
                                            _ b: OrderedDictionaryObject.Index)
    {
        guard let aow = a.owner else {
            preconditionFailure("no owner index")
        }
        
        guard let bow = b.owner else {
            preconditionFailure("no owner index")
        }
        
        guard aow === bow else {
            preconditionFailure("uncomparable index pair")
        }
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
            
            insert(newValue, key: key, before: endKey)
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

    public func insert(_ value: Value, key: Key, before rightKey: Key?) {
        if let rightKey = rightKey {
            remove(for: rightKey)
        }
        
        let rightIndex = self.index(for: rightKey)
        _insert(value, key: key, before: rightIndex)
    }
    
    private func _insert(_ value: Value, key: Key, before rightIndex: Index) {
        let rightKeyListIndex = self.keyListIndex(for: rightIndex)
        let keyListIndex = keyList.insert(key, at: rightKeyListIndex)
        let entry = Entry(value: value, keyListIndex: keyListIndex)
        dictionary[key] = entry
    }
    
    public var startKey: Key? {
        return self.startIndex.key
    }
    
    public var endKey: Key? {
        return self.endIndex.key
    }
    
    public func key(after key: Key?) -> Key? {
        let index = self.index(for: key)
        let nextIndex = self.index(after: index)
        return nextIndex.key
    }
    
    public func key(before key: Key?) -> Key? {
        let index = self.index(for: key)
        let prevIndex = self.index(before: index)
        return prevIndex.key
    }
    
    public func copy() -> OrderedDictionaryObject<Key, Value> {
        return OrderedDictionaryObject(uniqueKeysWithValues: map { ($0, $1) })
    }
}

extension OrderedDictionaryObject : Collection {
    public subscript(position: Index) -> (key: Key, value: Value) {
        checkValidIndex(position)
        
        guard let key = position.key,
            let entry = dictionary[key] else
        {
            preconditionFailure("Index out of range")
        }
        
        return (key: key, value: entry.value)
    }
    
    public var startIndex: Index {
        return self.index(for: keyList.startIndex)
    }
    
    public var endIndex: Index {
        return self.index(for: keyList.endIndex)
    }
    
    public func index(after i: Index) -> Index {
        let keyListIndex = self.keyListIndex(for: i)
        let nextKeyListIndex = keyList.index(after: keyListIndex)
        return self.index(for: nextKeyListIndex)
    }
    
    public func index(before i: Index) -> Index {
        let keyListIndex = self.keyListIndex(for: i)
        let prevKeyListIndex = keyList.index(before: keyListIndex)
        return self.index(for: prevKeyListIndex)
    }
    
    private func keyListIndex(for index: Index) -> KeyList.Index {
        checkValidIndex(index)
        guard let key = index.key else {
            return keyList.endIndex
        }
        return keyListIndex(for: key)
    }
    
    private func index(for keyListIndex: KeyList.Index) -> Index {
        if keyListIndex == keyList.endIndex {
            return Index(owner: self, key: nil)
        }
        let key = keyList[keyListIndex]
        return Index(owner: self, key: key)
    }
    
    public func index(for key: Key?) -> Index {
        let keyListIndex = self.keyListIndex(for: key)
        return index(for: keyListIndex)
    }
    
    private func keyListIndex(for key: Key?) -> KeyList.Index {
        guard let key = key,
            let entry = dictionary[key] else
        {
            return keyList.endIndex
        }
        return entry.keyListIndex
    }
    
    public var count: Int {
        return keyList.count
    }
    
    private func checkValidIndex(_ index: Index) {
        precondition(self === index.owner, "index for other object")
    }
}

extension OrderedDictionaryObject : BidirectionalCollection {}

