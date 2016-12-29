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
        Object>(_ index: YapDB.Index) -> Object? where
        Object: Persistable,
        Object: NSCoding {
            return readAtIndex(index) as? Object
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, Object>(_ indexes: Indexes) -> [Object] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        Object: Persistable,
        Object: NSCoding {
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        Object>(_ key: String) -> Object? where
        Object: Persistable,
        Object: NSCoding {
            return readAtIndex(Object.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, Object>(_ keys: Keys) -> [Object] where
        Keys: Sequence,
        Keys.Iterator.Element == String,
        Object: Persistable,
        Object: NSCoding {
            return readAtIndexes(Object.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        Object>() -> [Object] where
        Object: Persistable,
        Object: NSCoding {
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
        Object>(_ index: YapDB.Index) -> Object? where
        Object: Persistable,
        Object: NSCoding {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        Indexes, Object>(_ indexes: Indexes) -> [Object] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        Object: Persistable,
        Object: NSCoding {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        Object>(_ key: String) -> Object? where
        Object: Persistable,
        Object: NSCoding {
            return readAtIndex(Object.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        Keys, Object>(_ keys: Keys) -> [Object] where
        Keys: Sequence,
        Keys.Iterator.Element == String,
        Object: Persistable,
        Object: NSCoding {
            return readAtIndexes(Object.indexesWithKeys(keys))
    }

    /**
    Reads all the items in the database.

    - returns: an array of `ItemType`
    */
    public func readAll<
        Object>() -> [Object] where
        Object: Persistable,
        Object: NSCoding {
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
        Object>(_ item: Object) -> Object where
        Object: Persistable,
        Object: NSCoding {
            writeAtIndex(item.index, object: item, metadata: .none)
            return item
    }

    /**
    Write the items to the database using the transaction.

    - parameter items: a SequenceType of items to store.
    - returns: the same items, in an array.
    */
    public func write<
        Items, Object>(_ items: Items) -> [Object] where
        Items: Sequence,
        Items.Iterator.Element == Object,
        Object: Persistable,
        Object: NSCoding {
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
        Object>(_ item: Object) -> Object where
        Object: Persistable,
        Object: NSCoding {
            return write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - returns: the same items, in an array.
    */
    public func write<
        Items, Object>(_ items: Items) -> [Object] where
        Items: Sequence,
        Items.Iterator.Element == Object,
        Object: Persistable,
        Object: NSCoding {
            return write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.

    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Object>(_ item: Object, queue: DispatchQueue = DispatchQueue.main, completion: ((Object) -> Void)? = .none) where
        Object: Persistable,
        Object: NSCoding {
            asyncWrite({ $0.write(item) }, queue: queue, completion: completion)
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.

    - parameter items: a SequenceType of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        Items, Object>(_ items: Items, queue: DispatchQueue = DispatchQueue.main, completion: (([Object]) -> Void)? = .none) where
        Items: Sequence,
        Items.Iterator.Element == Object,
        Object: Persistable,
        Object: NSCoding {
            asyncWrite({ $0.write(items) }, queue: queue, completion: completion)
    }
}



