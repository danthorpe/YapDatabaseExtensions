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
    Self: ValueCoding,
    Self.MetadataType == Void,
    Self.Coder: NSCoding,
    Self.Coder.ValueType == Self {

    // Writing

    /**
    Write the item using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    - returns: the receiver.
    */
    public func write<WriteTransaction: WriteTransactionType>(transaction: WriteTransaction) -> Self {
        return transaction.write(self)
    }

    /**
    Write the item synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: the receiver.
    */
    public func write<Connection: ConnectionType>(connection: Connection) -> Self {
        return connection.write(self)
    }

    /**
    Write the item asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWrite<Connection: ConnectionType>(connection: Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Self -> Void)? = .None) {
        return connection.asyncWrite(self, queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeOperation<Connection: ConnectionType>(connection: Connection) -> NSOperation {
        return NSBlockOperation { connection.write(self) }
    }
}

extension SequenceType where
    Generator.Element: Persistable,
    Generator.Element: ValueCoding,
    Generator.Element.MetadataType == Void,
    Generator.Element.Coder: NSCoding,
    Generator.Element.Coder.ValueType == Generator.Element {

    /**
    Write the items using an existing transaction.

    - parameter transaction: a WriteTransactionType e.g. YapDatabaseReadWriteTransaction
    - returns: the receiver.
    */
    public func write<WriteTransaction: WriteTransactionType>(transaction: WriteTransaction) -> [Generator.Element] {
        return transaction.write(self)
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a ConnectionType e.g. YapDatabaseConnection
    - returns: the receiver.
    */
    public func write<Connection: ConnectionType>(connection: Connection) -> [Generator.Element] {
        return connection.write(self)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a ConnectionType e.g. YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWrite<Connection: ConnectionType>(connection: Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Generator.Element] -> Void)? = .None) {
        return connection.asyncWrite(self, queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeOperation<Connection: ConnectionType>(connection: Connection) -> NSOperation {
        return NSBlockOperation { connection.write(self) }
    }
}

// MARK: - Readable

extension Readable where
    ItemType: ValueCoding,
    ItemType: Persistable,
    ItemType.MetadataType == Void,
    ItemType.Coder: NSCoding,
    ItemType.Coder.ValueType == ItemType {

    func inTransaction(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType? {
        return transaction.readAtIndex(index)
    }

    func inTransactionAtIndex(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction<
        Indexes where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index>(indexes: Indexes) -> Database.Connection.ReadTransaction -> [ItemType] {
            let atIndex = inTransactionAtIndex
            return { indexes.flatMap(atIndex($0)) }
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

    func byKeysInTransaction(keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [ItemType] {
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
    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func atIndexes<
        Indexes where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index>(indexes: Indexes) -> [ItemType] {
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

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func byKeys<
        Keys where
        Keys: SequenceType,
        Keys.Generator.Element == String>(keys: Keys) -> [ItemType] {
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

