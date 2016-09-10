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
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(index: YapDB.Index) -> (Object, Metadata?)? {
            guard let item: Object = readAtIndex(index) else { return nil }
            let metadata: Metadata? = readMetadataAtIndex(index)
            return (item, metadata)
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, Object, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(indexes: Indexes) -> [(Object, Metadata?)] {
            // FIXME: using flatMap means the output length need not match the input length
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item by key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(key: String) -> (Object, Metadata?)? {
            return readAtIndex(Object.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, Object, Metadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(keys: Keys) -> [(Object, Metadata?)] {
            return readAtIndexes(Object.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>() -> [(Object, Metadata?)] {
            return readByKeys(keysInCollection(Object.collection))
    }
}

extension ConnectionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readAtIndex<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(index: YapDB.Index) -> (Object, Metadata?)? {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, Object, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(indexes: Indexes) -> [(Object, Metadata?)] {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(key: String) -> (Object, Metadata?)? {
            return readAtIndex(Object.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, Object, Metadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(keys: Keys) -> [(Object, Metadata?)] {
            return readAtIndexes(Object.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>() -> [(Object, Metadata?)] {
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
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(item: (Object, Metadata?)) -> (Object, Metadata?) {
            writeAtIndex(item.0.index, object: item.0, metadata: item.1)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func write<
        Items, Object, Metadata where
        Items: SequenceType,
        Items.Generator.Element == (Object, Metadata?),
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(items: Items) -> [(Object, Metadata?)] {
            return items.map(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.

    - parameter item: the item to store.
    */
    public func write<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(item: (Object, Metadata?)) -> (Object, Metadata?) {
            return write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    */
    public func write<
        Items, Object, Metadata where
        Items: SequenceType,
        Items.Generator.Element == (Object, Metadata?),
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(items: Items) -> [(Object, Metadata?)] {
            return write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Object, Metadata where
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(item: (Object, Metadata?), queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ((Object, Metadata?) -> Void)? = .None) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Items, Object, Metadata where
        Items: SequenceType,
        Items.Generator.Element == (Object, Metadata?),
        Object: Persistable,
        Object: NSCoding,
        Metadata: NSCoding>(items: Items, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([(Object, Metadata?)] -> Void)? = .None) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: completion)
    }
}



