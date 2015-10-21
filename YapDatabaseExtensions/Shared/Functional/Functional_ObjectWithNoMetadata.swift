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

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, ObjectWithNoMetadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(indexes: Indexes) -> [ObjectWithNoMetadata] {
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

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, ObjectWithNoMetadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(keys: Keys) -> [ObjectWithNoMetadata] {
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

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, ObjectWithNoMetadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(indexes: Indexes) -> [ObjectWithNoMetadata] {
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

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, ObjectWithNoMetadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(keys: Keys) -> [ObjectWithNoMetadata] {
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
    - returns: the same item
    */
    public func write<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(item: ObjectWithNoMetadata) -> ObjectWithNoMetadata {
            writeAtIndex(item.index, object: item, metadata: .None)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    - returns: the same items, in an array.
    */
    public func write<
        Items, ObjectWithNoMetadata where
        Items: SequenceType,
        Items.Generator.Element == ObjectWithNoMetadata,
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(items: Items) -> [ObjectWithNoMetadata] {
            return items.map(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - returns: the same item
    */
    public func write<
        ObjectWithNoMetadata where
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(item: ObjectWithNoMetadata) -> ObjectWithNoMetadata {
            return write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - returns: the same items, in an array.
    */
    public func write<
        Items, ObjectWithNoMetadata where
        Items: SequenceType,
        Items.Generator.Element == ObjectWithNoMetadata,
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(items: Items) -> [ObjectWithNoMetadata] {
            return write { $0.write(items) }
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
        ObjectWithNoMetadata.MetadataType == Void>(item: ObjectWithNoMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (ObjectWithNoMetadata -> Void)? = .None) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Items, ObjectWithNoMetadata where
        Items: SequenceType,
        Items.Generator.Element == ObjectWithNoMetadata,
        ObjectWithNoMetadata: Persistable,
        ObjectWithNoMetadata: NSCoding,
        ObjectWithNoMetadata.MetadataType == Void>(items: Items, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([ObjectWithNoMetadata] -> Void)? = .None) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: completion)
    }
}



