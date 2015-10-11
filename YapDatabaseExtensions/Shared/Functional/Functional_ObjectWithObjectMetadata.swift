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
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(index: YapDB.Index) -> ObjectWithObjectMetadata? {
            if var item = readAtIndex(index) as? ObjectWithObjectMetadata {
                item.metadata = readMetadataAtIndex(index) as? ObjectWithObjectMetadata.MetadataType
                return item
            }
            return .None
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(indexes: [YapDB.Index]) -> [ObjectWithObjectMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(key: String) -> ObjectWithObjectMetadata? {
            return readAtIndex(ObjectWithObjectMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(keys: [String]) -> [ObjectWithObjectMetadata] {
            return readAtIndexes(ObjectWithObjectMetadata.indexesWithKeys(keys))
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
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(index: YapDB.Index) -> ObjectWithObjectMetadata? {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(indexes: [YapDB.Index]) -> [ObjectWithObjectMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(key: String) -> ObjectWithObjectMetadata? {
            return readAtIndex(ObjectWithObjectMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(keys: [String]) -> [ObjectWithObjectMetadata] {
            return readAtIndexes(ObjectWithObjectMetadata.indexesWithKeys(keys))
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
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(item: ObjectWithObjectMetadata) {
            writeAtIndex(item.index, object: item, metadata: item.metadata)
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: an array of items to store.
    */
    public func write<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(items: [ObjectWithObjectMetadata]) {
            items.forEach(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func write<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(item: ObjectWithObjectMetadata) {
            write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: an array of items to store.
    */
    public func write<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(items: [ObjectWithObjectMetadata]) {
            write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(item: ObjectWithObjectMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: { _ in completion() })
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: an array of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ObjectWithObjectMetadata where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(items: [ObjectWithObjectMetadata], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: { _ in completion() })
    }
}



