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
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(transaction: WriteTransaction, metadata: Metadata?) -> YapItem<Self, Metadata> {
        return transaction.writeWithMetadata(YapItem(self, metadata))
    }

    /**
    Write the item synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: the receiver.
    */
    public func writeWithMetadata<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(connection: Connection, metadata: Metadata?) -> YapItem<Self, Metadata> {
        return connection.writeWithMetadata(YapItem(self, metadata))
    }

    /**
    Write the item asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    - returns: a closure which receives as an argument the receiver of this function.
    */
    public func asyncWriteWithMetadata<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(connection: Connection, metadata: Metadata?, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (YapItem<Self, Metadata> -> Void)? = .None) {
        return connection.asyncWriteWithMetadata(YapItem(self, metadata), queue: queue, completion: completion)
    }

    /**
    Write the item synchronously using a connection as an NSOperation

    - parameter connection: a YapDatabaseConnection
    - returns: an `NSOperation`
    */
    public func writeWithMetadataOperation<
        Connection, Metadata where
        Connection: ConnectionType,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(connection: Connection, metadata: Metadata?) -> NSOperation {
        return NSBlockOperation { connection.writeWithMetadata(YapItem(self, metadata)) }
    }
}

extension SequenceType where
    Generator.Element: Persistable,
    Generator.Element: ValueCoding,
    Generator.Element.Coder: NSCoding,
    Generator.Element.Coder.ValueType == Generator.Element {

    /**
     Zips the receiver with metadata into an array of YapItem.
     Assumes `self` and `metadata` have the same `count`.

     - parameter metadata: a sequence of optional metadatas.
     - returns: an array where Persistables and Metadata with corresponding indexes in `self` and `metadata` are joined in a `YapItem`
     */
    public func yapItems<
        Metadatas, Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata,
        Metadatas: SequenceType,
        Metadatas.Generator.Element == Optional<Metadata>>(with metadata: Metadatas) -> [YapItem<Generator.Element, Metadata>] {
        return zip(self, metadata).map { YapItem($0, $1) }
    }

    /**
    Write the items using an existing transaction.

    - parameter transaction: a WriteTransactionType e.g. YapDatabaseReadWriteTransaction
    - returns: the receiver.
    */
    public func writeWithMetadata<
        WriteTransaction, Metadata where
        WriteTransaction: WriteTransactionType,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(transaction: WriteTransaction, metadata: [Metadata?]) -> [YapItem<Generator.Element, Metadata>] {
        let items = yapItems(with: metadata)
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
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(connection: Connection, metadata: [Metadata?]) -> [YapItem<Generator.Element, Metadata>] {
        let items = yapItems(with: metadata)
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
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(connection: Connection, metadata: [Metadata?], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([YapItem<Generator.Element, Metadata>] -> Void)? = .None) {
        let items = yapItems(with: metadata)
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
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(connection: Connection, metadata: [Metadata?]) -> NSOperation {
        let items = yapItems(with: metadata)
        return NSBlockOperation { connection.writeWithMetadata(items) }
    }
}

// MARK: - Readable

extension Readable where
    ItemType: ValueCoding,
    ItemType: Persistable,
    ItemType.Coder: NSCoding,
    ItemType.Coder.ValueType == ItemType {

    func withMetadataInTransaction<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> YapItem<ItemType, Metadata>? {
        return transaction.readWithMetadataAtIndex(index)
    }

    func withMetadataInTransactionAtIndex<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> YapItem<ItemType, Metadata>? {
        return { self.withMetadataInTransaction(transaction, atIndex: $0) }
    }

    func withMetadataAtIndexInTransaction<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(index: YapDB.Index) -> Database.Connection.ReadTransaction -> YapItem<ItemType, Metadata>? {
        return { self.withMetadataInTransaction($0, atIndex: index) }
    }

    func withMetadataAtIndexesInTransaction<
        Indexes, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(indexes: Indexes) -> Database.Connection.ReadTransaction -> [YapItem<ItemType, Metadata>] {
        return { indexes.flatMap(self.withMetadataInTransactionAtIndex($0)) }
    }

    func withMetadataInTransaction<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(transaction: Database.Connection.ReadTransaction, byKey key: String) -> YapItem<ItemType, Metadata>? {
        return withMetadataInTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func withMetadataInTransactionByKey<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(transaction: Database.Connection.ReadTransaction) -> String -> YapItem<ItemType, Metadata>? {
        return { self.withMetadataInTransaction(transaction, byKey: $0) }
    }

    func withMetadataByKeyInTransaction<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(key: String) -> Database.Connection.ReadTransaction -> YapItem<ItemType, Metadata>? {
        return { self.withMetadataInTransaction($0, byKey: key) }
    }

    func withMetadataByKeysInTransaction<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [YapItem<ItemType, Metadata>] {
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
    public func withMetadataAtIndex<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(index: YapDB.Index) -> YapItem<ItemType, Metadata>? {
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
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(indexes: Indexes) -> [YapItem<ItemType, Metadata>] {
            return sync(withMetadataAtIndexesInTransaction(indexes))
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func withMetadataByKey<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(key: String) -> YapItem<ItemType, Metadata>? {
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
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(keys: Keys) -> [YapItem<ItemType, Metadata>] {
            return sync(withMetadataByKeysInTransaction(Array(keys)))
    }

    /**
    Reads all the `ItemType` in the database.

    - returns: an array of `ItemType`
    */
    public func withMetadataAll<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>() -> [YapItem<ItemType, Metadata>] {
        return sync(withMetadataByKeysInTransaction())
    }

    /**
    Returns th existing items and missing keys..

    - parameter keys: a SequenceType of String values
    - returns: a tuple of type `([ItemType], [String])`
    */
    public func withMetadataFilterExisting<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(keys: [String]) -> (existing: [YapItem<ItemType, Metadata>], missing: [String]) {
        let existingInTransaction: Database.Connection.ReadTransaction -> [YapItem<ItemType, Metadata>] = withMetadataByKeysInTransaction(keys)
        return sync { transaction -> ([YapItem<ItemType, Metadata>], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map {keyForPersistable($0.value)}
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}
