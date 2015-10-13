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
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(index: YapDB.Index) -> ValueWithNoMetadata? {
            return ValueWithNoMetadata.decode(readAtIndex(index))
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(indexes: [YapDB.Index]) -> [ValueWithNoMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(key: String) -> ValueWithNoMetadata? {
            return readAtIndex(ValueWithNoMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(keys: [String]) -> [ValueWithNoMetadata] {
            return readAtIndexes(ValueWithNoMetadata.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>() -> [ValueWithNoMetadata] {
            return readByKeys(keysInCollection(ValueWithNoMetadata.collection))
    }
}

extension ConnectionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readAtIndex<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(index: YapDB.Index) -> ValueWithNoMetadata? {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(indexes: [YapDB.Index]) -> [ValueWithNoMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(key: String) -> ValueWithNoMetadata? {
            return readAtIndex(ValueWithNoMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(keys: [String]) -> [ValueWithNoMetadata] {
            return readAtIndexes(ValueWithNoMetadata.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>() -> [ValueWithNoMetadata] {
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
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(item: ValueWithNoMetadata) {
            writeAtIndex(item.index, object: item.encoded, metadata: .None)
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: an array of items to store.
    */
    public func write<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(items: [ValueWithNoMetadata]) {
            items.forEach(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func write<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(item: ValueWithNoMetadata) {
            write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: an array of items to store.
    */
    public func write<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(items: [ValueWithNoMetadata]) {
            write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(item: ValueWithNoMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: { _ in completion() })
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: an array of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ValueWithNoMetadata where
        ValueWithNoMetadata: Persistable,
        ValueWithNoMetadata: ValueCoding,
        ValueWithNoMetadata.Coder: NSCoding,
        ValueWithNoMetadata.Coder.ValueType == ValueWithNoMetadata,
        ValueWithNoMetadata.MetadataType == Void>(items: [ValueWithNoMetadata], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: { _ in completion() })
    }
}

