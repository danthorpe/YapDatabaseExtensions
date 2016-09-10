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
    Self.Coder: NSCoding,
    Self.Coder.ValueType == Self {

    // Writing

    /**
    Write the item using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    - returns: the receiver.
    */
    public func write<
        WriteTransaction, Metadata where
        WriteTransaction: WriteTransactionType,
        Metadata: NSCoding>(transaction: WriteTransaction, metadata: Metadata? = nil) -> (Self, Metadata?) {
        return transaction.write((self, metadata))
    }

    /**
    Write the item synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: the receiver.
    */
    public func write<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: Metadata? = nil) -> (Self, Metadata?) {
        return connection.write((self, metadata))
    }

    /**
    Write the item asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWrite<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: Metadata? = nil, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ((Self, Metadata?) -> Void)? = .None) {
        return connection.asyncWrite((self, metadata), queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeOperation<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: Metadata? = nil) -> NSOperation {
        return NSBlockOperation { connection.write((self, metadata)) }
    }
}

extension SequenceType where
    Generator.Element: Persistable,
    Generator.Element: ValueCoding,
    Generator.Element.Coder: NSCoding,
    Generator.Element.Coder.ValueType == Generator.Element {

    /**
    Write the items using an existing transaction.

    - parameter transaction: a WriteTransactionType e.g. YapDatabaseReadWriteTransaction
    - returns: the receiver.
    */
    public func write<
        WriteTransaction, Metadata where
        WriteTransaction: WriteTransactionType,
        Metadata: NSCoding>(transaction: WriteTransaction, metadata: [Metadata?] = []) -> [(Generator.Element, Metadata?)] {
        let items = enumerate().map({ (index, element) in (element, metadata[index]) })
        return transaction.write(items)
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a ConnectionType e.g. YapDatabaseConnection
    - returns: the receiver.
    */
    public func write<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: [Metadata?] = []) -> [(Generator.Element, Metadata?)] {
        let items = enumerate().map({ (index, element) in (element, metadata[index]) })
        return connection.write(items)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a ConnectionType e.g. YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWrite<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: [Metadata?] = [], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([(Generator.Element, Metadata?)] -> Void)? = .None) {
        let items = enumerate().map({ (index, element) in (element, metadata[index]) })
        return connection.asyncWrite(items, queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeOperation<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: [Metadata?] = []) -> NSOperation {
        let items = enumerate().map({ (index, element) in (element, metadata[index]) })
        return NSBlockOperation { connection.write(items) }
    }
}


// MARK: - Readable

extension Readable where
    ItemType: ValueCoding,
    ItemType: Persistable,
    ItemType.Coder: NSCoding,
    ItemType.Coder.ValueType == ItemType {

    func inTransaction<Metadata: NSCoding>(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> (ItemType, Metadata?)? {
        return transaction.readAtIndex(index)
    }

    func inTransactionAtIndex<Metadata: NSCoding>(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> (ItemType, Metadata?)? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction<Metadata: NSCoding>(index: YapDB.Index) -> Database.Connection.ReadTransaction -> (ItemType, Metadata?)? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction<
        Indexes, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Metadata: NSCoding>(indexes: Indexes) -> Database.Connection.ReadTransaction -> [(ItemType, Metadata?)] {
            return { indexes.flatMap(self.inTransactionAtIndex($0)) }
    }

    func inTransaction<Metadata: NSCoding>(transaction: Database.Connection.ReadTransaction, byKey key: String) -> (ItemType, Metadata?)? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionByKey<Metadata: NSCoding>(transaction: Database.Connection.ReadTransaction) -> String -> (ItemType, Metadata?)? {
        return { self.inTransaction(transaction, byKey: $0) }
    }

    func byKeyInTransaction<Metadata: NSCoding>(key: String) -> Database.Connection.ReadTransaction -> (ItemType, Metadata?)? {
        return { self.inTransaction($0, byKey: key) }
    }

    func byKeysInTransaction<Metadata: NSCoding>(keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [(ItemType, Metadata?)] {
        return { transaction in
            let keys = keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(self.inTransactionByKey(transaction))
        }
    }

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func atIndex<Metadata: NSCoding>(index: YapDB.Index) -> (ItemType, Metadata?)? {
        return sync(atIndexInTransaction(index))
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func atIndexes<
        Indexes, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Metadata: NSCoding>(indexes: Indexes) -> [(ItemType, Metadata?)] {
            return sync(atIndexesInTransaction(indexes))
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func byKey<Metadata: NSCoding>(key: String) -> (ItemType, Metadata?)? {
        return sync(byKeyInTransaction(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func byKeys<
        Keys, Metadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Metadata: NSCoding>(keys: Keys) -> [(ItemType, Metadata?)] {
            return sync(byKeysInTransaction(Array(keys)))
    }

    /**
    Reads all the `ItemType` in the database.

    - returns: an array of `ItemType`
    */
    public func all<Metadata: NSCoding>() -> [(ItemType, Metadata?)] {
        return sync(byKeysInTransaction())
    }

    /**
    Returns th existing items and missing keys..

    - parameter keys: a SequenceType of String values
    - returns: a tuple of type `([ItemType], [String])`
    */
    public func filterExisting<Metadata: NSCoding>(keys: [String]) -> (existing: [(ItemType, Metadata?)], missing: [String]) {
        let existingInTransaction: Database.Connection.ReadTransaction -> [(ItemType, Metadata?)] = byKeysInTransaction(keys)
        return sync { transaction -> ([(ItemType, Metadata?)], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map {keyForPersistable($0.0)}
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}
