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
        ValueWithValueMetadata where
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(index: YapDB.Index) -> ValueWithValueMetadata? {
            if var item = ValueWithValueMetadata.decode(readAtIndex(index)) {
                item.metadata = readMetadataAtIndex(index)
                return item
            }
            return .None
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, ValueWithValueMetadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(indexes: Indexes) -> [ValueWithValueMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ValueWithValueMetadata where
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(key: String) -> ValueWithValueMetadata? {
            return readAtIndex(ValueWithValueMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, ValueWithValueMetadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(keys: Keys) -> [ValueWithValueMetadata] {
            return readAtIndexes(ValueWithValueMetadata.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        ValueWithValueMetadata where
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>() -> [ValueWithValueMetadata] {
            return readByKeys(keysInCollection(ValueWithValueMetadata.collection))
    }
}

extension ConnectionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readAtIndex<
        ValueWithValueMetadata where
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(index: YapDB.Index) -> ValueWithValueMetadata? {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, ValueWithValueMetadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(indexes: Indexes) -> [ValueWithValueMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ValueWithValueMetadata where
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(key: String) -> ValueWithValueMetadata? {
            return readAtIndex(ValueWithValueMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, ValueWithValueMetadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(keys: Keys) -> [ValueWithValueMetadata] {
            return readAtIndexes(ValueWithValueMetadata.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        ValueWithValueMetadata where
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>() -> [ValueWithValueMetadata] {
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
        ValueWithValueMetadata where
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(item: ValueWithValueMetadata) -> ValueWithValueMetadata {
            writeAtIndex(item.index, object: item.encoded, metadata: item.metadata?.encoded)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func write<
        Items, ValueWithValueMetadata where
        Items: SequenceType,
        Items.Generator.Element == ValueWithValueMetadata,
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(items: Items) -> [ValueWithValueMetadata] {
            return items.map(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func write<
        ValueWithValueMetadata where
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(item: ValueWithValueMetadata) -> ValueWithValueMetadata {
            return write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func write<
        Items, ValueWithValueMetadata where
        Items: SequenceType,
        Items.Generator.Element == ValueWithValueMetadata,
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(items: Items) -> [ValueWithValueMetadata] {
            return write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ValueWithValueMetadata where
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(item: ValueWithValueMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (ValueWithValueMetadata -> Void)? = .None) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Items, ValueWithValueMetadata where
        Items: SequenceType,
        Items.Generator.Element == ValueWithValueMetadata,
        ValueWithValueMetadata: Persistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(items: Items, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([ValueWithValueMetadata] -> Void)? = .None) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: completion)
    }
}


