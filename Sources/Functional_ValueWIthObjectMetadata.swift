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
    public func readWithMetadataAtIndex<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(index: YapDB.Index) -> YapItem<Value, Metadata>? {
            guard let item: Value = Value.decode(readAtIndex(index)) else { return nil }
            let metadata: Metadata? = readMetadataAtIndex(index)
            return YapItem(item, metadata)
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataAtIndexes<
        Indexes, Value, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(indexes: Indexes) -> [YapItem<Value, Metadata>] {
            // FIXME: using flatMap means the output length need not match the input length
            return indexes.flatMap(readWithMetadataAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readWithMetadataByKey<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(key: String) -> YapItem<Value, Metadata>? {
            return readWithMetadataAtIndex(Value.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataByKeys<
        Keys, Value, Metadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(keys: Keys) -> [YapItem<Value, Metadata>] {
            return readWithMetadataAtIndexes(Value.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readWithMetadataAll<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>() -> [YapItem<Value, Metadata>] {
            return readWithMetadataByKeys(keysInCollection(Value.collection))
    }
}

extension ConnectionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readWithMetadataAtIndex<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(index: YapDB.Index) -> YapItem<Value, Metadata>? {
            return read { $0.readWithMetadataAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataAtIndexes<
        Indexes, Value, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(indexes: Indexes) -> [YapItem<Value, Metadata>] {
            return read { $0.readWithMetadataAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readWithMetadataByKey<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(key: String) -> YapItem<Value, Metadata>? {
            return readWithMetadataAtIndex(Value.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataByKeys<
        Keys, Value, Metadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(keys: Keys) -> [YapItem<Value, Metadata>] {
            return readWithMetadataAtIndexes(Value.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readWithMetadataAll<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>() -> [YapItem<Value, Metadata>] {
            return read { $0.readWithMetadataAll() }
    }
}

// MARK: - Writing

extension WriteTransactionType {

    /**
    Write the item to the database using the transaction.

    - parameter item: the item to store.
    */
    public func writeWithMetadata<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(item: YapItem<Value, Metadata>) -> YapItem<Value, Metadata> {
            writeAtIndex(item.value.index, object: item.value.encoded, metadata: item.metadata)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func writeWithMetadata<
        Items, Value, Metadata where
        Items: SequenceType,
        Items.Generator.Element == YapItem<Value, Metadata>,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(items: Items) -> [YapItem<Value, Metadata>] {
            return items.map(writeWithMetadata)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func writeWithMetadata<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(item: YapItem<Value, Metadata>) -> YapItem<Value, Metadata> {
            return write { $0.writeWithMetadata(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func writeWithMetadata<
        Items, Value, Metadata where
        Items: SequenceType,
        Items.Generator.Element == YapItem<Value, Metadata>,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(items: Items) -> [YapItem<Value, Metadata>] {
            return write { $0.writeWithMetadata(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWriteWithMetadata<
        Value, Metadata where
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(item: YapItem<Value, Metadata>, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (YapItem<Value, Metadata> -> Void)? = .None) {
            asyncWrite({ $0.writeWithMetadata(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWriteWithMetadata<
        Items, Value, Metadata where
        Items: SequenceType,
        Items.Generator.Element == YapItem<Value, Metadata>,
        Value: Persistable,
        Value: ValueCoding,
        Value.Coder: NSCoding,
        Value.Coder.ValueType == Value,
        Metadata: NSCoding>(items: Items, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([YapItem<Value, Metadata>] -> Void)? = .None) {
            asyncWrite({ $0.writeWithMetadata(items) }, queue: queue, completion: completion)
    }
}

