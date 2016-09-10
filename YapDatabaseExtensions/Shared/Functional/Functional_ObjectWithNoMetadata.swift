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
        Object where
        Object: Persistable,
        Object: NSCoding>(index: YapDB.Index) -> Object? {
            return readAtIndex(index) as? Object
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, Object where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Object: Persistable,
        Object: NSCoding>(indexes: Indexes) -> [Object] {
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        Object where
        Object: Persistable,
        Object: NSCoding>(key: String) -> Object? {
            return readAtIndex(Object.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, Object where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Object: Persistable,
        Object: NSCoding>(keys: Keys) -> [Object] {
            return readAtIndexes(Object.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        Object where
        Object: Persistable,
        Object: NSCoding>() -> [Object] {
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
        Object where
        Object: Persistable,
        Object: NSCoding>(index: YapDB.Index) -> Object? {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, Object where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Object: Persistable,
        Object: NSCoding>(indexes: Indexes) -> [Object] {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        Object where
        Object: Persistable,
        Object: NSCoding>(key: String) -> Object? {
            return readAtIndex(Object.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, Object where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Object: Persistable,
        Object: NSCoding>(keys: Keys) -> [Object] {
            return readAtIndexes(Object.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        Object where
        Object: Persistable,
        Object: NSCoding>() -> [Object] {
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
        Object where
        Object: Persistable,
        Object: NSCoding>(item: Object) -> Object {
            writeAtIndex(item.index, object: item, metadata: .None)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    - returns: the same items, in an array.
    */
    public func write<
        Items, Object where
        Items: SequenceType,
        Items.Generator.Element == Object,
        Object: Persistable,
        Object: NSCoding>(items: Items) -> [Object] {
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
        Object where
        Object: Persistable,
        Object: NSCoding>(item: Object) -> Object {
            return write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - returns: the same items, in an array.
    */
    public func write<
        Items, Object where
        Items: SequenceType,
        Items.Generator.Element == Object,
        Object: Persistable,
        Object: NSCoding>(items: Items) -> [Object] {
            return write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Object where
        Object: Persistable,
        Object: NSCoding>(item: Object, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Object -> Void)? = .None) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Items, Object where
        Items: SequenceType,
        Items.Generator.Element == Object,
        Object: Persistable,
        Object: NSCoding>(items: Items, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Object] -> Void)? = .None) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: completion)
    }
}



