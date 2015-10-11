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
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(index: YapDB.Index) -> ObjectWithValueMetadata? {
            if var item = readAtIndex(index) as? ObjectWithValueMetadata {
                item.metadata = ObjectWithValueMetadata.MetadataType.decode(readMetadataAtIndex(index))
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
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(indexes: [YapDB.Index]) -> [ObjectWithValueMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(key: String) -> ObjectWithValueMetadata? {
            return readAtIndex(ObjectWithValueMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(keys: [String]) -> [ObjectWithValueMetadata] {
            return readAtIndexes(ObjectWithValueMetadata.indexesWithKeys(keys))
    }
}

extension ConnectionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readAtIndex<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(index: YapDB.Index) -> ObjectWithValueMetadata? {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(indexes: [YapDB.Index]) -> [ObjectWithValueMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(key: String) -> ObjectWithValueMetadata? {
            return readAtIndex(ObjectWithValueMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(keys: [String]) -> [ObjectWithValueMetadata] {
            return readAtIndexes(ObjectWithValueMetadata.indexesWithKeys(keys))
    }
}

// MARK: - Reading

extension WriteTransactionType {

    /**
    Write the item to the database using the transaction.

    - parameter item: the item to store.
    */
    public func write<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(item: ObjectWithValueMetadata) {
            writeAtIndex(item.index, object: item, metadata: item.metadata?.encoded)
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: an array of items to store.
    */
    public func write<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(items: [ObjectWithValueMetadata]) {
            items.forEach(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func write<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(item: ObjectWithValueMetadata) {
            write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: an array of items to store.
    */
    public func write<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(items: [ObjectWithValueMetadata]) {
            write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(item: ObjectWithValueMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: { _ in completion() })
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: an array of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(items: [ObjectWithValueMetadata], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: { _ in completion() })
    }
}


