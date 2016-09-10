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
    public func writeWithMetadata<
        WriteTransaction, Metadata where
        WriteTransaction: WriteTransactionType,
        Metadata: NSCoding>(transaction: WriteTransaction, metadata: Metadata?) -> (Self, Metadata?) {
        return transaction.writeWithMetadata((self, metadata))
    }

    /**
    Write the item synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: the receiver.
    */
    public func writeWithMetadata<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: Metadata?) -> (Self, Metadata?) {
        return connection.writeWithMetadata((self, metadata))
    }

    /**
    Write the item asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWriteWithMetadata<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: Metadata?, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ((Self, Metadata?) -> Void)? = .None) {
        return connection.asyncWriteWithMetadata((self, metadata), queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeWithMetadataOperation<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: Metadata?) -> NSOperation {
        return NSBlockOperation { connection.writeWithMetadata((self, metadata)) }
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
    public func writeWithMetadata<
        WriteTransaction, Metadata where
        WriteTransaction: WriteTransactionType,
        Metadata: NSCoding>(transaction: WriteTransaction, metadata: [Metadata?]) -> [(Generator.Element, Metadata?)] {
        let items = zipToWrite(self, metadata)
        return transaction.writeWithMetadata(items)
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a ConnectionType e.g. YapDatabaseConnection
    - returns: the receiver.
    */
    public func writeWithMetadata<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: [Metadata?]) -> [(Generator.Element, Metadata?)] {
        let items = zipToWrite(self, metadata)
        return connection.writeWithMetadata(items)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a ConnectionType e.g. YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWriteWithMetadata<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: [Metadata?], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([(Generator.Element, Metadata?)] -> Void)? = .None) {
        let items = zipToWrite(self, metadata)
        return connection.asyncWriteWithMetadata(items, queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeWithMetadataOperation<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: NSCoding>(connection: Connection, metadata: [Metadata?]) -> NSOperation {
        let items = zipToWrite(self, metadata)
        return NSBlockOperation { connection.writeWithMetadata(items) }
    }
}


// MARK: - Readable

extension Readable where
    ItemType: ValueCoding,
    ItemType: Persistable,
    ItemType.Coder: NSCoding,
    ItemType.Coder.ValueType == ItemType {

    func withMetadataInTransaction<Metadata: NSCoding>(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> (ItemType, Metadata?)? {
        return transaction.readWithMetadataAtIndex(index)
    }

    func withMetadataInTransactionAtIndex<Metadata: NSCoding>(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> (ItemType, Metadata?)? {
        return { self.withMetadataInTransaction(transaction, atIndex: $0) }
    }

    func withMetadataAtIndexInTransaction<Metadata: NSCoding>(index: YapDB.Index) -> Database.Connection.ReadTransaction -> (ItemType, Metadata?)? {
        return { self.withMetadataInTransaction($0, atIndex: index) }
    }

    func withMetadataAtIndexesInTransaction<
        Indexes, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Metadata: NSCoding>(indexes: Indexes) -> Database.Connection.ReadTransaction -> [(ItemType, Metadata?)] {
            return { indexes.flatMap(self.withMetadataInTransactionAtIndex($0)) }
    }

    func withMetadataInTransaction<Metadata: NSCoding>(transaction: Database.Connection.ReadTransaction, byKey key: String) -> (ItemType, Metadata?)? {
        return withMetadataInTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func withMetadataInTransactionByKey<Metadata: NSCoding>(transaction: Database.Connection.ReadTransaction) -> String -> (ItemType, Metadata?)? {
        return { self.withMetadataInTransaction(transaction, byKey: $0) }
    }

    func withMetadataByKeyInTransaction<Metadata: NSCoding>(key: String) -> Database.Connection.ReadTransaction -> (ItemType, Metadata?)? {
        return { self.withMetadataInTransaction($0, byKey: key) }
    }

    func withMetadataByKeysInTransaction<Metadata: NSCoding>(keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [(ItemType, Metadata?)] {
        return { transaction in
            let keys = keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(self.withMetadataInTransactionByKey(transaction))
        }
    }

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func withMetadataAtIndex<Metadata: NSCoding>(index: YapDB.Index) -> (ItemType, Metadata?)? {
        return sync(withMetadataAtIndexInTransaction(index))
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func withMetadataAtIndexes<
        Indexes, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Metadata: NSCoding>(indexes: Indexes) -> [(ItemType, Metadata?)] {
            return sync(withMetadataAtIndexesInTransaction(indexes))
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func withMetadataByKey<Metadata: NSCoding>(key: String) -> (ItemType, Metadata?)? {
        return sync(withMetadataByKeyInTransaction(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func withMetadataByKeys<
        Keys, Metadata where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        Metadata: NSCoding>(keys: Keys) -> [(ItemType, Metadata?)] {
            return sync(withMetadataByKeysInTransaction(Array(keys)))
    }

    /**
    Reads all the `ItemType` in the database.

    - returns: an array of `ItemType`
    */
    public func withMetadataAll<Metadata: NSCoding>() -> [(ItemType, Metadata?)] {
        return sync(withMetadataByKeysInTransaction())
    }

    /**
    Returns th existing items and missing keys..

    - parameter keys: a SequenceType of String values
    - returns: a tuple of type `([ItemType], [String])`
    */
    public func withMetadataFilterExisting<Metadata: NSCoding>(keys: [String]) -> (existing: [(ItemType, Metadata?)], missing: [String]) {
        let existingInTransaction: Database.Connection.ReadTransaction -> [(ItemType, Metadata?)] = withMetadataByKeysInTransaction(keys)
        return sync { transaction -> ([(ItemType, Metadata?)], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map {keyForPersistable($0.0)}
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}
