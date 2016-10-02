//
//  Persistable_AnyWithValueMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 13/10/2015.
//
//

import Foundation
import ValueCoding

// MARK: - Readable

extension Readable where
    ItemType: Persistable,
    ItemType.MetadataType: ValueCoding,
    ItemType.MetadataType.Coder: NSCoding,
    ItemType.MetadataType.Coder.ValueType == ItemType.MetadataType {

    func metadataInTransaction(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType.MetadataType? {
        return transaction.readMetadataAtIndex(index)
    }

    func metadataAtIndexInTransaction(index: YapDB.Index) -> Database.Connection.ReadTransaction -> ItemType.MetadataType? {
        return { self.metadataInTransaction($0, atIndex: index) }
    }

    func metadataInTransactionAtIndex(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> ItemType.MetadataType? {
        return { self.metadataInTransaction(transaction, atIndex: $0) }
    }

    func metadataAtIndexesInTransaction<
        Indexes where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index>(indexes: Indexes) -> Database.Connection.ReadTransaction -> [ItemType.MetadataType] {
            let atIndex = metadataInTransactionAtIndex
            return { indexes.flatMap(atIndex($0)) }
    }

    /**
    Reads the metadata at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `ItemType.MetadataType`
    */
    public func metadataAtIndex(index: YapDB.Index) -> ItemType.MetadataType? {
        return sync(metadataAtIndexInTransaction(index))
    }

    /**
    Reads the metadata at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `ItemType.MetadataType`
    */
    public func metadataAtIndexes<
        Indexes where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index>(indexes: Indexes) -> [ItemType.MetadataType] {
            return sync(metadataAtIndexesInTransaction(indexes))
    }
}
