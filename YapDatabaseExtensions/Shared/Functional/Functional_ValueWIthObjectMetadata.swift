//
//  Functional_ObjectWithNoMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 11/10/2015.
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
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(index: YapDB.Index) -> (Value, Metadata?)? {
            guard let item: Value = Value.decode(readAtIndex(index)) else { return nil }
            let metadata: Metadata? = readMetadataAtIndex(index)
            return (item, metadata)
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, Value, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(indexes: Indexes) -> [(Value, Metadata?)] {
            // FIXME: using flatMap means the output length need not match the input length
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(key: String) -> (Value, Metadata?)? {
            return readAtIndex(Value.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, Value, Metadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(keys: Keys) -> [(Value, Metadata?)] {
            return readAtIndexes(Value.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>() -> [(Value, Metadata?)] {
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
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(index: YapDB.Index) -> (Value, Metadata?)? {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, Value, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(indexes: Indexes) -> [(Value, Metadata?)] {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(key: String) -> (Value, Metadata?)? {
            return readAtIndex(Value.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, Value, Metadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(keys: Keys) -> [(Value, Metadata?)] {
            return readAtIndexes(Value.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>() -> [(Value, Metadata?)] {
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
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(item: (Value, Metadata?)) -> (Value, Metadata?) {
            writeAtIndex(item.0.index, object: item.0.encoded, metadata: item.1)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func write<
        Items, Value, Metadata where
        Items: SequenceType,
        Items.Generator.Element == (Value, Metadata?),
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(items: Items) -> [(Value, Metadata?)] {
            return items.map(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func write<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(item: (Value, Metadata?)) -> (Value, Metadata?) {
            return write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func write<
        Items, Value, Metadata where
        Items: SequenceType,
        Items.Generator.Element == (Value, Metadata?),
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(items: Items) -> [(Value, Metadata?)] {
            return write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(item: (Value, Metadata?), queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ((Value, Metadata?) -> Void)? = .None) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Items, Value, Metadata where
        Items: SequenceType,
        Items.Generator.Element == (Value, Metadata?),
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(items: Items, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([(Value, Metadata?)] -> Void)? = .None) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: completion)
    }
}

