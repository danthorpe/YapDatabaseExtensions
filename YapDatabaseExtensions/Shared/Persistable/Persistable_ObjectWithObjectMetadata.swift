//
//  Persistable_ObjectWithNoMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 11/10/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Readable

extension Readable where
    ItemType: NSCoding,
    ItemType: MetadataPersistable,
    ItemType.MetadataType: NSCoding {

    func inTransaction(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType? {
        return transaction.readAtIndex(index)
    }

    // Everything here is the same for all 6 patterns.

    func inTransactionAtIndex(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> Database.Connection.ReadTransaction -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction))
        }
    }

    func inTransaction(transaction: Database.Connection.ReadTransaction, byKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionByKey(transaction: Database.Connection.ReadTransaction) -> String -> ItemType? {
        return { self.inTransaction(transaction, byKey: $0) }
    }

    func byKeyInTransaction(key: String) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, byKey: key) }
    }

    func byKeysInTransaction(_keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [ItemType] {
        let byKey = inTransactionByKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(byKey(transaction))
        }
    }

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType`
    */
    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func byKey(key: String) -> ItemType? {
        return sync(byKeyInTransaction(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(byKeysInTransaction(keys))
    }

    /**
    Reads all the `ItemType` in the database.

    - returns: an array of `ItemType`
    */
    public func all() -> [ItemType] {
        return sync(byKeysInTransaction())
    }

    /**
    Returns th existing items and missing keys..

    - parameter keys: an array of String
    - returns: a tuple of type `([ItemType], [String])`
    */
    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = byKeysInTransaction(keys)
        return sync { transaction -> ([ItemType], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map(keyForPersistable)
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}

// MARK: - Writable

extension Writable
    where
    ItemType: NSCoding,
    ItemType: MetadataPersistable,
    ItemType.MetadataType: NSCoding {

    /**
    Write the items using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    */
    public func on(transaction: Database.Connection.WriteTransaction) {
        transaction.write(items)
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func sync(connection: Database.Connection) {
        connection.write(on)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func async(connection: Database.Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
        connection.asyncWrite(on, queue: queue, completion: completion)
    }

    /**
    Write the items inside of an `NSOperation`.

    - parameter connection: a YapDatabaseConnection
    */
    public func operation(connection: Database.Connection) -> NSOperation {
        return connection.writeBlockOperation { self.on($0) }
    }
}
