//
//  Read_ValueWithValueMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 11/10/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Value with Value metadata

extension Readable where
    ItemType: ValueCoding,
    ItemType: MetadataPersistable,
    ItemType.Coder: NSCoding,
    ItemType.Coder.ValueType == ItemType,
    ItemType.MetadataType: ValueCoding,
    ItemType.MetadataType.Coder: NSCoding,
    ItemType.MetadataType.Coder.ValueType == ItemType.MetadataType {

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

// MARK: - Value with Value metadata

extension ReadTransactionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readAtIndex<
        ValueWithValueMetadata where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(index: YapDB.Index) -> ValueWithValueMetadata? {
            if var item = ValueWithValueMetadata.decode(readAtIndex(index)) {
                item.metadata = ValueWithValueMetadata.MetadataType.decode(readMetadataAtIndex(index))
                return item
            }
            return .None
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        ValueWithValueMetadata where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(indexes: [YapDB.Index]) -> [ValueWithValueMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ValueWithValueMetadata where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(key: String) -> ValueWithValueMetadata? {
            return readAtIndex(ValueWithValueMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        ValueWithValueMetadata where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(keys: [String]) -> [ValueWithValueMetadata] {
            return readAtIndexes(ValueWithValueMetadata.indexesWithKeys(keys))
    }
}

extension ConnectionType {

    /**
    Reads the item at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType`
    */
    public func readAtIndex<
        ValueWithValueMetadata where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(index: YapDB.Index) -> ValueWithValueMetadata? {
            return read { $0.readAtIndex(index) }
    }

    /**
    Reads the items at the indexes.

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType`
    */
    public func readAtIndexes<
        ValueWithValueMetadata where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(indexes: [YapDB.Index]) -> [ValueWithValueMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    /**
    Reads the item at the key.

    - parameter key: a String
    - returns: an optional `ItemType`
    */
    public func readByKey<
        ValueWithValueMetadata where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(key: String) -> ValueWithValueMetadata? {
            return readAtIndex(ValueWithValueMetadata.indexWithKey(key))
    }

    /**
    Reads the items by the keys.

    - parameter keys: an array of String
    - returns: an array of `ItemType`
    */
    public func readByKeys<
        ValueWithValueMetadata where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(keys: [String]) -> [ValueWithValueMetadata] {
            return readAtIndexes(ValueWithValueMetadata.indexesWithKeys(keys))
    }
}

