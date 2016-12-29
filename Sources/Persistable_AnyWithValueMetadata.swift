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
    ItemType: Persistable {

    func metadataInTransaction<
        Metadata>(_ transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> Metadata? where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
        return transaction.readMetadataAtIndex(index)
    }

    func metadataAtIndexInTransaction<
        Metadata>(_ index: YapDB.Index) -> (Database.Connection.ReadTransaction) -> Metadata? where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
        return { self.metadataInTransaction($0, atIndex: index) }
    }

    func metadataInTransactionAtIndex<
        Metadata>(_ transaction: Database.Connection.ReadTransaction) -> (YapDB.Index) -> Metadata? where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
        return { self.metadataInTransaction(transaction, atIndex: $0) }
    }

    func metadataAtIndexesInTransaction<
        Indexes, Metadata>(_ indexes: Indexes) -> (Database.Connection.ReadTransaction) -> [Metadata] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
            return { indexes.flatMap(self.metadataInTransactionAtIndex($0)) }
    }

    /**
    Reads the metadata at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `Metadata`
    */
    public func metadataAtIndex<
        Metadata>(_ index: YapDB.Index) -> Metadata? where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
        return sync(metadataAtIndexInTransaction(index))
    }

    /**
    Reads the metadata at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `Metadata`
    */
    public func metadataAtIndexes<
        Indexes, Metadata>(_ indexes: Indexes) -> [Metadata] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
            return sync(metadataAtIndexesInTransaction(indexes))
    }
}
