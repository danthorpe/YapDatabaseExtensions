//
//  Created by Daniel Thorpe on 22/04/2015.
//
//

import YapDatabase

extension YapDatabaseReadTransaction {

    /**
        Reads the object sored at this index using the transaction.
        :param: index The YapDatabase.Index value.
        :returns: An optional AnyObject.
    */
    public func readAtIndex(index: YapDatabase.Index) -> AnyObject? {
        return objectForKey(index.key, inCollection: index.collection)
    }

    /**
        Reads the object sored at this index using the transaction.
        :param: index The YapDatabase.Index value.
        :returns: An optional Object.
    */
    public func readAtIndex<Object where Object: Persistable>(index: YapDatabase.Index) -> Object? {
        return readAtIndex(index) as? Object
    }

    /**
        Unarchives a value type if stored at this index
        :param: index The YapDatabase.Index value.
        :returns: An optional Value.
    */
    public func readAtIndex<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(index: YapDatabase.Index) -> Value? {
        return valueFromArchive(readAtIndex(index))
    }
}

extension YapDatabaseReadTransaction {

    /**
        Reads the object sored at these indexes using the transaction.
        :param: indexes An array of YapDatabase.Index values.
        :returns: An array of Object instances.
    */
    public func readAtIndexes<Object where Object: Persistable>(indexes: [YapDatabase.Index]) -> [Object] {
        return map(indexes, readAtIndex)
    }

    /**
        Reads the value sored at these indexes using the transaction.
        :param: indexes An array of YapDatabase.Index values.
        :returns: An array of Value instances.
    */
    public func readAtIndexes<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(indexes: [YapDatabase.Index]) -> [Value] {
        return map(indexes, readAtIndex)
    }
}

extension YapDatabaseReadTransaction {

    public func read<Object where Object: Persistable>(key: String) -> Object? {
        return objectForKey(key, inCollection: Object.collection) as? Object
    }

    public func read<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> Value? {
        return valueFromArchive(objectForKey(key, inCollection: Value.collection))
    }
}

extension YapDatabaseReadTransaction {

    public func read<Object where Object: Persistable>(keys: [String]) -> [Object] {
        return map(keys, read)
    }

    public func read<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> [Value] {
        return map(keys, read)
    }
}

extension YapDatabaseReadTransaction {

    public func readAll<Object where Object: Persistable>() -> [Object] {
        return map(allKeysInCollection(Object.collection) as! [String], read)
    }

    public func readAll<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>() -> [Value] {
        return map(allKeysInCollection(Value.collection) as! [String], read)
    }
}

extension YapDatabaseReadTransaction {

    public func filterExisting<Object where Object: Persistable>(keys: [String]) -> (existing: [Object], missing: [String]) {
        let existing: [Object] = read(keys)
        let existingKeys = existing.map { indexForPersistable($0).key }
        let missingKeys = filter(keys) { !contains(existingKeys, $0) }
        return (existing, missingKeys)
    }

    public func filterExisting<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> (existing: [Value], missing: [String]) {
        let existing: [Value] = read(keys)
        let existingKeys = existing.map { indexForPersistable($0).key }
        let missingKeys = filter(keys) { !contains(existingKeys, $0) }
        return (existing, missingKeys)
    }
}


// MARK: - YapDatabaseConnection

extension YapDatabaseConnection {

    public func readAtIndex(index: YapDatabase.Index) -> AnyObject? {
        return read({ $0.readAtIndex(index) })
    }

    public func readAtIndex<Object where Object: Persistable>(index: YapDatabase.Index) -> Object? {
        return read({ $0.readAtIndex(index) })
    }

    public func readAtIndex<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(index: YapDatabase.Index) -> Value? {
        return read({ $0.readAtIndex(index) })
    }

}

extension YapDatabaseConnection {

    public func readAtIndexes<Object where Object: Persistable>(indexes: [YapDatabase.Index]) -> [Object] {
        return read({ $0.readAtIndexes(indexes) })
    }

    public func readAtIndexes<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(indexes: [YapDatabase.Index]) -> [Value] {
        return read({ $0.readAtIndexes(indexes) })
    }
}

extension YapDatabaseConnection {

    public func read<Object where Object: Persistable>(key: String) -> Object? {
        return read({ $0.read(key) })
    }

    public func read<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> Value? {
        return read({ $0.read(key) })
    }
}

extension YapDatabaseConnection {

    public func read<Object where Object: Persistable>(keys: [String]) -> [Object] {
        return read({ $0.read(keys) })
    }

    public func read<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> [Value] {
        return read({ $0.read(keys) })
    }
}

extension YapDatabaseConnection {

    public func readAll<Object where Object: Persistable>() -> [Object] {
        return read({ $0.readAll() })
    }

    public func readAll<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>() -> [Value] {
        return read({ $0.readAll() })
    }
}

extension YapDatabaseConnection {

    public func filterExisting<Object where Object: Persistable>(keys: [String]) -> (existing: [Object], missing: [String]) {
        return read({ $0.filterExisting(keys) })
    }

    public func filterExisting<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> (existing: [Value], missing: [String]) {
        return read({ $0.filterExisting(keys) })
    }
}

// MARK: Async Methods

extension YapDatabaseConnection {

    public func asyncReadAtIndex<Object where Object: Persistable>(index: YapDatabase.Index, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Object?) -> Void) {
        asyncRead({ $0.readAtIndex(index) }, queue: queue, completion: completion)
    }

    public func asyncReadAtIndex<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(index: YapDatabase.Index, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Value?) -> Void) {
        asyncRead({ $0.readAtIndex(index) }, queue: queue, completion: completion)
    }
}

extension YapDatabaseConnection {

    public func asyncReadAtIndexes<Object where Object: Persistable>(indexes: [YapDatabase.Index], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Object]) -> Void) {
        asyncRead({ $0.readAtIndexes(indexes) }, queue: queue, completion: completion)
    }

    public func asyncReadAtIndexes<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(indexes: [YapDatabase.Index], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Value]) -> Void) {
        asyncRead({ $0.readAtIndexes(indexes) }, queue: queue, completion: completion)
    }
}

extension YapDatabaseConnection {

    public func asyncRead<Object where Object: Persistable>(key: String, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Object?) -> Void) {
        asyncRead({ $0.read(key) }, queue: queue, completion: completion)
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Value?) -> Void) {
        asyncRead({ $0.read(key) }, queue: queue, completion: completion)
    }
}

extension YapDatabaseConnection {

    public func asyncRead<Object where Object: Persistable>(keys: [String], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Object]) -> Void) {
        asyncRead({ $0.read(keys) }, queue: queue, completion: completion)
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Value]) -> Void) {
        asyncRead({ $0.read(keys) }, queue: queue, completion: completion)
    }
}

extension YapDatabaseConnection {

    public func asyncReadAll<Object where Object: Persistable>(queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Object]) -> Void) {
        asyncRead({ $0.readAll() }, queue: queue, completion: completion)
    }

    public func asyncReadAll<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Value]) -> Void) {
        asyncRead({ $0.readAll() }, queue: queue, completion: completion)
    }
}


// MARK: - YapDatabase

extension YapDatabase {

    public func readAtIndex<Object where Object: Persistable>(index: YapDatabase.Index) -> Object? {
        return newConnection().readAtIndex(index)
    }

    public func readAtIndex<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(index: YapDatabase.Index) -> Value? {
        return newConnection().readAtIndex(index)
    }
}

extension YapDatabase {

    public func readAtIndexes<Object where Object: Persistable>(indexes: [YapDatabase.Index]) -> [Object] {
        return newConnection().readAtIndexes(indexes)
    }

    public func readAtIndexes<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(indexes: [YapDatabase.Index]) -> [Value] {
        return newConnection().readAtIndexes(indexes)
    }
}

extension YapDatabase {

    public func read<Object where Object: Persistable>(key: String) -> Object? {
        return newConnection().read(key)
    }

    public func read<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> Value? {
        return newConnection().read(key)
    }
}

extension YapDatabase {

    public func read<Object where Object: Persistable>(keys: [String]) -> [Object] {
        return newConnection().read(keys)
    }

    public func read<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> [Value] {
        return newConnection().read(keys)
    }
}

extension YapDatabase {

    public func readAll<Object where Object: Persistable>() -> [Object] {
        return newConnection().readAll()
    }

    public func readAll<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>() -> [Value] {
        return newConnection().readAll()
    }
}

extension YapDatabase {

    public func filterExisting<Object where Object: Persistable>(keys: [String]) -> (existing: [Object], missing: [String]) {
        return newConnection().filterExisting(keys)
    }

    public func filterExisting<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> (existing: [Value], missing: [String]) {
        return newConnection().filterExisting(keys)
    }
}


// MARK: Async Methods

extension YapDatabase {

    public func asyncReadAtIndex<Object where Object: Persistable>(index: YapDatabase.Index, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Object?) -> Void) {
        newConnection().asyncReadAtIndex(index, queue: queue, completion: completion)
    }

    public func asyncReadAtIndex<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(index: YapDatabase.Index, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Value?) -> Void) {
        newConnection().asyncReadAtIndex(index, queue: queue, completion: completion)
    }
}

extension YapDatabase {

    public func asyncRead<Object where Object: Persistable>(key: String, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Object?) -> Void) {
        newConnection().asyncRead(key, queue: queue, completion: completion)
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Value?) -> Void) {
        newConnection().asyncRead(key, queue: queue, completion: completion)
    }
}

extension YapDatabase {

    public func asyncRead<Object where Object: Persistable>(keys: [String], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Object]) -> Void) {
        newConnection().asyncRead(keys, queue: queue, completion: completion)
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Value]) -> Void) {
        newConnection().asyncRead(keys, queue: queue, completion: completion)
    }
}

extension YapDatabase {

    public func asyncReadAll<Object where Object: Persistable>(queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Object]) -> Void) {
        newConnection().asyncReadAll(queue: queue, completion: completion)
    }

    public func asyncReadAll<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Value]) -> Void) {
        newConnection().asyncReadAll(queue: queue, completion: completion)
    }
}

