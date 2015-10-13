//
//  Functional_ObjectWithNoMetadata.swift
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
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(index: YapDB.Index) -> ObjectWithNoMetadata? {
            return readAtIndex(index) as? ObjectWithNoMetadata
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(indexes: [YapDB.Index]) -> [ObjectWithNoMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(key: String) -> ObjectWithNoMetadata? {
            return readAtIndex(ObjectWithNoMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(keys: [String]) -> [ObjectWithNoMetadata] {
            return readAtIndexes(ObjectWithNoMetadata.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>() -> [ObjectWithNoMetadata] {
            return readByKeys(keysInCollection(ObjectWithNoMetadata.collection))
    }
}

extension ConnectionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readAtIndex<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(index: YapDB.Index) -> ObjectWithNoMetadata? {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(indexes: [YapDB.Index]) -> [ObjectWithNoMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(key: String) -> ObjectWithNoMetadata? {
            return readAtIndex(ObjectWithNoMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(keys: [String]) -> [ObjectWithNoMetadata] {
            return readAtIndexes(ObjectWithNoMetadata.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>() -> [ObjectWithNoMetadata] {
            return read { $0.readAll() }
    }
}

// MARK: - Writable

extension WriteTransactionType {

    /**
    Write the item to the database using the transaction.

    - parameter item: the item to store.
    */
    public func write<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(item: ObjectWithNoMetadata) {
            writeAtIndex(item.index, object: item, metadata: .None)
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: an array of items to store.
    */
    public func write<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(items: [ObjectWithNoMetadata]) {
            items.forEach(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func write<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(item: ObjectWithNoMetadata) {
            write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: an array of items to store.
    */
    public func write<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(items: [ObjectWithNoMetadata]) {
            write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(item: ObjectWithNoMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: { _ in completion() })
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: an array of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(items: [ObjectWithNoMetadata], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: { _ in completion() })
    }
}



