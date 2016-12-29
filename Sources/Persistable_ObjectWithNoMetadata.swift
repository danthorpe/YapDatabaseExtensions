//
//  Persistable_ObjectWithNoMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 11/10/2015.
//
//

import Foundation
import ValueCoding

// MARK: - Persistable

extension Persistable where
    Self: NSCoding {

    // Writing

    /**
    Write the item using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    - returns: the receiver.
    */
    public func write<WriteTransaction: WriteTransactionType>(_ transaction: WriteTransaction) -> Self {
        return transaction.write(self)
    }

    /**
    Write the item synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: the receiver.
    */
    public func write<Connection: ConnectionType>(_ connection: Connection) -> Self {
        return connection.write(self)
    }

    /**
    Write the item asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWrite<Connection: ConnectionType>(_ connection: Connection, queue: DispatchQueue = DispatchQueue.main, completion: ((Self) -> Void)? = .none) {
        return connection.asyncWrite(self, queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeOperation<Connection: ConnectionType>(_ connection: Connection) -> Operation {
        return BlockOperation { connection.write(self) }
    }
}

extension Sequence where
    Iterator.Element: Persistable,
    Iterator.Element: NSCoding {

    /**
    Write the items using an existing transaction.

    - parameter transaction: a WriteTransactionType e.g. YapDatabaseReadWriteTransaction
    - returns: the receiver.
    */
    public func write<WriteTransaction: WriteTransactionType>(_ transaction: WriteTransaction) -> [Iterator.Element] {
        return transaction.write(self)
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a ConnectionType e.g. YapDatabaseConnection
    - returns: the receiver.
    */
    public func write<Connection: ConnectionType>(_ connection: Connection) -> [Iterator.Element] {
        return connection.write(self)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a ConnectionType e.g. YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWrite<Connection: ConnectionType>(_ connection: Connection, queue: DispatchQueue = DispatchQueue.main, completion: (([Iterator.Element]) -> Void)? = .none) {
        return connection.asyncWrite(self, queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeOperation<Connection: ConnectionType>(_ connection: Connection) -> Operation {
        return BlockOperation { connection.write(self) }
    }
}

// MARK: - Readable

extension Readable where
    ItemType: NSCoding,
    ItemType: Persistable {

    func inTransaction(_ transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType? {
        return transaction.readAtIndex(index)
    }

    func inTransactionAtIndex(_ transaction: Database.Connection.ReadTransaction) -> (YapDB.Index) -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(_ index: YapDB.Index) -> (Database.Connection.ReadTransaction) -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction<
        Indexes>(_ indexes: Indexes) -> (Database.Connection.ReadTransaction) -> [ItemType] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index {
            let atIndex = inTransactionAtIndex
            return { indexes.flatMap(atIndex($0)) }
    }

    func inTransaction(_ transaction: Database.Connection.ReadTransaction, byKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionByKey(_ transaction: Database.Connection.ReadTransaction) -> (String) -> ItemType? {
        return { self.inTransaction(transaction, byKey: $0) }
    }

    func byKeyInTransaction(_ key: String) -> (Database.Connection.ReadTransaction) -> ItemType? {
        return { self.inTransaction($0, byKey: key) }
    }

    func byKeysInTransaction(_ keys: [String]? = .none) -> (Database.Connection.ReadTransaction) -> [ItemType] {
        let byKey = inTransactionByKey
        return { transaction in
            let keys = keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(byKey(transaction))
        }
    }

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func atIndex(_ index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func atIndexes<
        Indexes>(_ indexes: Indexes) -> [ItemType] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index {
            return sync(atIndexesInTransaction(indexes))
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func byKey(_ key: String) -> ItemType? {
        return sync(byKeyInTransaction(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func byKeys<
        Keys>(_ keys: Keys) -> [ItemType] where
        Keys: Sequence,
        Keys.Iterator.Element == String {
            return sync(byKeysInTransaction(Array(keys)))
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

    - parameter keys: a SequenceType of String values
    - returns: a tuple of type `([ItemType], [String])`
    */
    public func filterExisting(_ keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = byKeysInTransaction(keys)
        return sync { transaction -> ([ItemType], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map(keyForPersistable)
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}

