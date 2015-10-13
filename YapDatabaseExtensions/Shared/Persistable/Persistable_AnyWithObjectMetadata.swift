//
//  Persistable_AnyWithObjectMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 13/10/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Readable

extension Readable where
    ItemType: Persistable,
    ItemType.MetadataType: NSCoding {

    func metadataInTransaction(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType.MetadataType? {
        return transaction.readMetadataAtIndex(index)
    }

    func metadataAtIndexInTransaction(index: YapDB.Index) -> Database.Connection.ReadTransaction -> ItemType.MetadataType? {
        return { self.metadataInTransaction($0, atIndex: index) }
    }

    func metadataInTransactionAtIndex(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> ItemType.MetadataType? {
        return { self.metadataInTransaction(transaction, atIndex: $0) }
    }

    func metadataAtIndexesInTransaction(indexes: [YapDB.Index]) -> Database.Connection.ReadTransaction -> [ItemType.MetadataType] {
        let atIndex = metadataInTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction))
        }
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

    - parameter indexes: an Array<YapDB.Index>
    - returns: an array of `ItemType.MetadataType`
    */
    public func metadataAtIndexes(indexes: [YapDB.Index]) -> [ItemType.MetadataType] {
        return sync(metadataAtIndexesInTransaction(indexes))
    }
}
