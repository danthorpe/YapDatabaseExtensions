//
//  Functional_ValueWithNoMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 13/10/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Reading

extension ReadTransactionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readAtIndex<
        Value>(_ index: YapDB.Index) -> Value? where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return Value.decode(readAtIndex(index) as Any?)
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, Value>(_ indexes: Indexes) -> [Value] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        Value>(_ key: String) -> Value? where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return readAtIndex(Value.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, Value>(_ keys: Keys) -> [Value] where
        Keys: Sequence,
        Keys.Iterator.Element == String,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return readAtIndexes(Value.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        Value>() -> [Value] where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return readByKeys(keysInCollection(Value.collection))
    }
}

extension ConnectionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readAtIndex<
        Value>(_ index: YapDB.Index) -> Value? where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, Value>(_ indexes: Indexes) -> [Value] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        Value>(_ key: String) -> Value? where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return readAtIndex(Value.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, Value>(_ keys: Keys) -> [Value] where
        Keys: Sequence,
        Keys.Iterator.Element == String,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return readAtIndexes(Value.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        Value>() -> [Value] where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return read { $0.readAll() }
    }
}

// MARK: - Writing

extension WriteTransactionType {

    /**
    Write the item to the database using the transaction.

    - parameter item: the item to store.
    */
    public func write<
        Value>(_ item: Value) -> Value where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            writeAtIndex(item.index, object: item.encoded, metadata: .None)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func write<
        Items, Value>(_ items: Items) -> [Value] where
        Items: Sequence,
        Items.Iterator.Element == Value,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return items.map(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func write<
        Value>(_ item: Value) -> Value where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func write<
        Items, Value>(_ items: Items) -> [Value] where
        Items: Sequence,
        Items.Iterator.Element == Value,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            return write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Value>(_ item: Value, queue: DispatchQueue = DispatchQueue.main, completion: ((Value) -> Void)? = .none) where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            asyncWrite({ $0.write(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Items, Value>(_ items: Items, queue: DispatchQueue = DispatchQueue.main, completion: (([Value]) -> Void)? = .none) where
        Items: Sequence,
        Items.Iterator.Element == Value,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.Value == Value {
            asyncWrite({ $0.write(items) }, queue: queue, completion: completion)
    }
}

