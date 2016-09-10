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
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(index: YapDB.Index) -> (Object, Metadata?)? {
            guard let item: Object = readAtIndex(index) else { return nil }
            let metadata: Metadata? = readMetadataAtIndex(index)
            return (item, metadata)
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataAtIndexes<
        Indexes, Object, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(indexes: Indexes) -> [(Object, Metadata?)] {
            // FIXME: using flatMap means the output length need not match the input length
            return indexes.flatMap(readWithMetadataAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readWithMetadataByKey<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(key: String) -> (Object, Metadata?)? {
            return readWithMetadataAtIndex(Object.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataByKeys<
        Keys, Object, Metadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(keys: Keys) -> [(Object, Metadata?)] {
            return readWithMetadataAtIndexes(Object.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readWithMetadataAll<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>() -> [(Object, Metadata?)] {
            return readWithMetadataByKeys(keysInCollection(Object.collection))
    }
}

extension ConnectionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readWithMetadataAtIndex<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(index: YapDB.Index) -> (Object, Metadata?)? {
            return read { $0.readWithMetadataAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataAtIndexes<
        Indexes, Object, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(indexes: Indexes) -> [(Object, Metadata?)] {
            return read { $0.readWithMetadataAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readWithMetadataByKey<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(key: String) -> (Object, Metadata?)? {
            return readWithMetadataAtIndex(Object.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataByKeys<
        Keys, Object, Metadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(keys: Keys) -> [(Object, Metadata?)] {
            return readWithMetadataAtIndexes(Object.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readWithMetadataAll<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>() -> [(Object, Metadata?)] {
            return read { $0.readWithMetadataAll() }
    }
}

// MARK: - Reading

extension WriteTransactionType {

    /**
    Write the item to the database using the transaction.

    - parameter item: the item to store.
    */
    public func writeWithMetadata<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(item: (Object, Metadata?)) -> (Object, Metadata?) {
            writeAtIndex(item.0.index, object: item.0, metadata: item.1?.encoded)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func writeWithMetadata<
        Items, Object, Metadata where
        Items: SequenceType,
        Items.Generator.Element == (Object, Metadata?),
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(items: Items) -> [(Object, Metadata?)] {
            return items.map(writeWithMetadata)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func writeWithMetadata<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(item: (Object, Metadata?)) -> (Object, Metadata?) {
            return write { $0.writeWithMetadata(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func writeWithMetadata<
        Items, Object, Metadata where
        Items: SequenceType,
        Items.Generator.Element == (Object, Metadata?),
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(items: Items) -> [(Object, Metadata?)] {
            return write { $0.writeWithMetadata(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWriteWithMetadata<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(item: (Object, Metadata?), queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ((Object, Metadata?) -> Void)? = .None) {
            asyncWrite({ $0.writeWithMetadata(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWriteWithMetadata<
        Items, Object, Metadata where
        Items: SequenceType,
        Items.Generator.Element == (Object, Metadata?),
        Object: Persistable,
        Object: NSCoding,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(items: Items, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([(Object, Metadata?)] -> Void)? = .None) {
            asyncWrite({ $0.writeWithMetadata(items) }, queue: queue, completion: completion)
    }
}


