//
//  Read_ValueWithObjectMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 11/10/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Value with Object metadata

extension Readable
    where
    ItemType: ValueCoding,
    ItemType: MetadataPersistable,
    ItemType.Coder: NSCoding,
    ItemType.Coder.ValueType == ItemType,
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

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(byKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(byKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(byKeysInTransaction())
    }

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

// MARK: - Value with Object metadata

extension ReadTransactionType {

    public func readAtIndex<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(index: YapDB.Index) -> ValueWithObjectMetadata? {
            if var item = ValueWithObjectMetadata.decode(readAtIndex(index)) {
                item.metadata = readMetadataAtIndex(index) as? ValueWithObjectMetadata.MetadataType
                return item
            }
            return .None
    }

    public func readAtIndexes<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(indexes: [YapDB.Index]) -> [ValueWithObjectMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    public func readByKey<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(key: String) -> ValueWithObjectMetadata? {
            return readAtIndex(ValueWithObjectMetadata.indexWithKey(key))
    }

    public func readByKeys<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(keys: [String]) -> [ValueWithObjectMetadata] {
            return readAtIndexes(ValueWithObjectMetadata.indexesWithKeys(keys))
    }
}

extension ConnectionType {

    public func readAtIndex<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(index: YapDB.Index) -> ValueWithObjectMetadata? {
            return read { $0.readAtIndex(index) }
    }

    public func readAtIndexes<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(indexes: [YapDB.Index]) -> [ValueWithObjectMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    public func readByKey<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(key: String) -> ValueWithObjectMetadata? {
            return readAtIndex(ValueWithObjectMetadata.indexWithKey(key))
    }

    public func readByKeys<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(keys: [String]) -> [ValueWithObjectMetadata] {
            return readAtIndexes(ValueWithObjectMetadata.indexesWithKeys(keys))
    }
}



