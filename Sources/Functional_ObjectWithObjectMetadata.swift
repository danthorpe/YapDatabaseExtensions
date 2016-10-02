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
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(index: YapDB.Index) -> ObjectWithObjectMetadata? {
            if var item = readAtIndex(index) as? ObjectWithObjectMetadata {
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
        Indexes, ObjectWithObjectMetadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(indexes: Indexes) -> [ObjectWithObjectMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item by key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(key: String) -> ObjectWithObjectMetadata? {
            return readAtIndex(ObjectWithObjectMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, ObjectWithObjectMetadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(keys: Keys) -> [ObjectWithObjectMetadata] {
            return readAtIndexes(ObjectWithObjectMetadata.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>() -> [ObjectWithObjectMetadata] {
            return readByKeys(keysInCollection(ObjectWithObjectMetadata.collection))
    }
}

extension ConnectionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readAtIndex<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(index: YapDB.Index) -> ObjectWithObjectMetadata? {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, ObjectWithObjectMetadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(indexes: Indexes) -> [ObjectWithObjectMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(key: String) -> ObjectWithObjectMetadata? {
            return readAtIndex(ObjectWithObjectMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, ObjectWithObjectMetadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(keys: Keys) -> [ObjectWithObjectMetadata] {
            return readAtIndexes(ObjectWithObjectMetadata.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>() -> [ObjectWithObjectMetadata] {
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
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(item: ObjectWithObjectMetadata) -> ObjectWithObjectMetadata {
            writeAtIndex(item.index, object: item, metadata: item.metadata)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func write<
        Items, ObjectWithObjectMetadata where
        Items: SequenceType,
        Items.Generator.Element == ObjectWithObjectMetadata,
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(items: Items) -> [ObjectWithObjectMetadata] {
            return items.map(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func write<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(item: ObjectWithObjectMetadata) -> ObjectWithObjectMetadata {
            return write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func write<
        Items, ObjectWithObjectMetadata where
        Items: SequenceType,
        Items.Generator.Element == ObjectWithObjectMetadata,
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(items: Items) -> [ObjectWithObjectMetadata] {
            return write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(item: ObjectWithObjectMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (ObjectWithObjectMetadata -> Void)? = .None) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Items, ObjectWithObjectMetadata where
        Items: SequenceType,
        Items.Generator.Element == ObjectWithObjectMetadata,
        ObjectWithObjectMetadata: Persistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(items: Items, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([ObjectWithObjectMetadata] -> Void)? = .None) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: completion)
    }
}



