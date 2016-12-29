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
    Self.Coder.Value == Self {

    // Writing

    /**
    Write the item using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    - returns: the receiver.
    */
    public func writeWithMetadata<
        WriteTransaction, Metadata>(_ transaction: WriteTransaction, metadata: Metadata?) -> YapItem<Self, Metadata> where
        WriteTransaction: WriteTransactionType,
        Metadata: NSCoding {
        return transaction.writeWithMetadata(YapItem(self, metadata))
    }

    /**
    Write the item synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: the receiver.
    */
    public func writeWithMetadata<
        Connection, Metadata>(_ connection: Connection, metadata: Metadata?) -> YapItem<Self, Metadata> where
        Connection: ConnectionType,
        Metadata: NSCoding {
        return connection.writeWithMetadata(YapItem(self, metadata))
    }

    /**
    Write the item asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWriteWithMetadata<
        Connection, Metadata>(_ connection: Connection, metadata: Metadata?, queue: DispatchQueue = DispatchQueue.main, completion: ((YapItem<Self, Metadata>) -> Void)? = .none) where
        Connection: ConnectionType,
        Metadata: NSCoding {
        return connection.asyncWriteWithMetadata(YapItem(self, metadata), queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeWithMetadataOperation<
        Connection, Metadata>(_ connection: Connection, metadata: Metadata?) -> Operation where
        Connection: ConnectionType,
        Metadata: NSCoding {
        return BlockOperation { _ = connection.writeWithMetadata(YapItem(self, metadata)) }
    }
}

extension Sequence where
    Iterator.Element: Persistable,
    Iterator.Element: ValueCoding,
    Iterator.Element.Coder: NSCoding,
    Iterator.Element.Coder.Value == Iterator.Element {

    /**
     Zips the receiver with metadata into an array of YapItem.
     Assumes `self` and `metadata` have the same `count`.

     - parameter metadata: a sequence of optional metadatas.
     - returns: an array where Persistables and Metadata with corresponding indexes in `self` and `metadata` are joined in a `YapItem`
     */
    public func yapItems<
        Metadatas, Metadata>(with metadata: Metadatas) -> [YapItem<Iterator.Element, Metadata>] where
        Metadata: NSCoding,
        Metadatas: Sequence,
        Metadatas.Iterator.Element == Optional<Metadata> {
        return zip(self, metadata).map { YapItem($0, $1) }
    }

    /**
    Write the items using an existing transaction.

    - parameter transaction: a WriteTransactionType e.g. YapDatabaseReadWriteTransaction
    - returns: the receiver.
    */
    public func writeWithMetadata<
        WriteTransaction, Metadata>(_ transaction: WriteTransaction, metadata: [Metadata?]) -> [YapItem<Iterator.Element, Metadata>] where
        WriteTransaction: WriteTransactionType,
        Metadata: NSCoding {
        let items = yapItems(with: metadata)
        return transaction.writeWithMetadata(items)
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a ConnectionType e.g. YapDatabaseConnection
    - returns: the receiver.
    */
    public func writeWithMetadata<
        Connection, Metadata>(_ connection: Connection, metadata: [Metadata?]) -> [YapItem<Iterator.Element, Metadata>] where
        Connection: ConnectionType,
        Metadata: NSCoding {
        let items = yapItems(with: metadata)
        return connection.writeWithMetadata(items)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a ConnectionType e.g. YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWriteWithMetadata<
        Connection, Metadata>(_ connection: Connection, metadata: [Metadata?], queue: DispatchQueue = DispatchQueue.main, completion: (([YapItem<Iterator.Element, Metadata>]) -> Void)? = .none) where
        Connection: ConnectionType,
        Metadata: NSCoding {
        let items = yapItems(with: metadata)
        return connection.asyncWriteWithMetadata(items, queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeWithMetadataOperation<
        Connection, Metadata>(_ connection: Connection, metadata: [Metadata?]) -> Operation where
        Connection: ConnectionType,
        Metadata: NSCoding {
        let items = yapItems(with: metadata)
        return BlockOperation { _ = connection.writeWithMetadata(items) }
    }
}


// MARK: - Readable

extension Readable where
    ItemType: ValueCoding,
    ItemType: Persistable,
    ItemType.Coder: NSCoding,
    ItemType.Coder.Value == ItemType {

    func withMetadataInTransaction<Metadata: NSCoding>(_ transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> YapItem<ItemType, Metadata>? {
        return transaction.readWithMetadataAtIndex(index)
    }

    func withMetadataInTransactionAtIndex<Metadata: NSCoding>(_ transaction: Database.Connection.ReadTransaction) -> (YapDB.Index) -> YapItem<ItemType, Metadata>? {
        return { self.withMetadataInTransaction(transaction, atIndex: $0) }
    }

    func withMetadataAtIndexInTransaction<Metadata: NSCoding>(_ index: YapDB.Index) -> (Database.Connection.ReadTransaction) -> YapItem<ItemType, Metadata>? {
        return { self.withMetadataInTransaction($0, atIndex: index) }
    }

    func withMetadataAtIndexesInTransaction<
        Indexes, Metadata>(_ indexes: Indexes) -> (Database.Connection.ReadTransaction) -> [YapItem<ItemType, Metadata>] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        Metadata: NSCoding {
            return { indexes.flatMap(self.withMetadataInTransactionAtIndex($0)) }
    }

    func withMetadataInTransaction<Metadata: NSCoding>(_ transaction: Database.Connection.ReadTransaction, byKey key: String) -> YapItem<ItemType, Metadata>? {
        return withMetadataInTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func withMetadataInTransactionByKey<Metadata: NSCoding>(_ transaction: Database.Connection.ReadTransaction) -> (String) -> YapItem<ItemType, Metadata>? {
        return { self.withMetadataInTransaction(transaction, byKey: $0) }
    }

    func withMetadataByKeyInTransaction<Metadata: NSCoding>(_ key: String) -> (Database.Connection.ReadTransaction) -> YapItem<ItemType, Metadata>? {
        return { self.withMetadataInTransaction($0, byKey: key) }
    }

    func withMetadataByKeysInTransaction<Metadata: NSCoding>(_ keys: [String]? = .none) -> (Database.Connection.ReadTransaction) -> [YapItem<ItemType, Metadata>] {
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
    public func withMetadataAtIndex<Metadata: NSCoding>(_ index: YapDB.Index) -> YapItem<ItemType, Metadata>? {
        return sync(withMetadataAtIndexInTransaction(index))
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType`
    */
    public func withMetadataAtIndexes<
        Indexes, Metadata>(_ indexes: Indexes) -> [YapItem<ItemType, Metadata>] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        Metadata: NSCoding {
            return sync(withMetadataAtIndexesInTransaction(indexes))
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func withMetadataByKey<Metadata: NSCoding>(_ key: String) -> YapItem<ItemType, Metadata>? {
        return sync(withMetadataByKeyInTransaction(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: a SequenceType of String values
    - returns: an array of `ItemType`
    */
    public func withMetadataByKeys<
        Keys, Metadata>(_ keys: Keys) -> [YapItem<ItemType, Metadata>] where
        Keys: Sequence,
        Keys.Iterator.Element == String,
        Metadata: NSCoding {
            return sync(withMetadataByKeysInTransaction(Array(keys)))
    }

    /**
    Reads all the `ItemType` in the database.

    - returns: an array of `ItemType`
    */
    public func withMetadataAll<Metadata: NSCoding>() -> [YapItem<ItemType, Metadata>] {
        return sync(withMetadataByKeysInTransaction())
    }

    /**
    Returns th existing items and missing keys..

    - parameter keys: a SequenceType of String values
    - returns: a tuple of type `([ItemType], [String])`
    */
    public func withMetadataFilterExisting<Metadata: NSCoding>(_ keys: [String]) -> (existing: [YapItem<ItemType, Metadata>], missing: [String]) {
        let existingInTransaction: (Database.Connection.ReadTransaction) -> [YapItem<ItemType, Metadata>] = withMetadataByKeysInTransaction(keys)
        return sync { transaction -> ([YapItem<ItemType, Metadata>], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map {keyForPersistable($0.value)}
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}
