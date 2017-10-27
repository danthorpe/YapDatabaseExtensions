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
        Object, Metadata>(_ index: YapDB.Index) -> YapItem<Object, Metadata>? where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            guard let item: Object = readAtIndex(index) else { return nil }
            let metadata: Metadata? = readMetadataAtIndex(index)
            return YapItem(item, metadata)
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataAtIndexes<
        Indexes, Object, Metadata>(_ indexes: Indexes) -> [YapItem<Object, Metadata>?] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return indexes.map(readWithMetadataAtIndex)
    }

    /**
    Reads the item by key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readWithMetadataByKey<
        Object, Metadata>(_ key: String) -> YapItem<Object, Metadata>? where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return readWithMetadataAtIndex(Object.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataByKeys<
        Keys, Object, Metadata>(_ keys: Keys) -> [YapItem<Object, Metadata>?] where
        Keys: Sequence,
        Keys.Iterator.Element == String,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return readWithMetadataAtIndexes(Object.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readWithMetadataAll<
        Object, Metadata>() -> [YapItem<Object, Metadata>?] where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
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
        Object, Metadata>(_ index: YapDB.Index) -> YapItem<Object, Metadata>? where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return read { $0.readWithMetadataAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataAtIndexes<
        Indexes, Object, Metadata>(_ indexes: Indexes) -> [YapItem<Object, Metadata>?] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return read { $0.readWithMetadataAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readWithMetadataByKey<
        Object, Metadata>(_ key: String) -> YapItem<Object, Metadata>? where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return readWithMetadataAtIndex(Object.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readWithMetadataByKeys<
        Keys, Object, Metadata>(_ keys: Keys) -> [YapItem<Object, Metadata>?] where
        Keys: Sequence,
        Keys.Iterator.Element == String,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return readWithMetadataAtIndexes(Object.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readWithMetadataAll<
        Object, Metadata>() -> [YapItem<Object, Metadata>?] where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return read { $0.readWithMetadataAll() }
    }
}

// MARK: - Writable

extension WriteTransactionType {

    /**
    Write the item to the database using the transaction.

    - parameter item: the item to store.
    */
    public func writeWithMetadata<
        Object, Metadata>(_ item: YapItem<Object, Metadata>) -> YapItem<Object, Metadata> where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            writeAtIndex(item.value.index, object: item.value, metadata: item.metadata)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func writeWithMetadata<
        Items, Object, Metadata>(_ items: Items) -> [YapItem<Object, Metadata>] where
        Items: Sequence,
        Items.Iterator.Element == YapItem<Object, Metadata>,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return items.map(writeWithMetadata)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func writeWithMetadata<
        Object, Metadata>(_ item: YapItem<Object, Metadata>) -> YapItem<Object, Metadata> where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return write { $0.writeWithMetadata(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func writeWithMetadata<
        Items, Object, Metadata>(_ items: Items) -> [YapItem<Object, Metadata>] where
        Items: Sequence,
        Items.Iterator.Element == YapItem<Object, Metadata>,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            return write { $0.writeWithMetadata(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWriteWithMetadata<
        Object, Metadata>(_ item: YapItem<Object, Metadata>, queue: DispatchQueue = DispatchQueue.main, completion: ((YapItem<Object, Metadata>) -> Void)? = .none) where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            asyncWrite({ $0.writeWithMetadata(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWriteWithMetadata<
        Items, Object, Metadata>(_ items: Items, queue: DispatchQueue = DispatchQueue.main, completion: (([YapItem<Object, Metadata>]) -> Void)? = .none) where
        Items: Sequence,
        Items.Iterator.Element == YapItem<Object, Metadata>,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding {
            asyncWrite({ $0.writeWithMetadata(items) }, queue: queue, completion: completion)
    }
}



