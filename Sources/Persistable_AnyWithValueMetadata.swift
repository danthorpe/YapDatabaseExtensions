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
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> Metadata? {
        return transaction.readMetadataAtIndex(index)
    }

    func metadataAtIndexInTransaction<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(index: YapDB.Index) -> Database.Connection.ReadTransaction -> Metadata? {
        return { self.metadataInTransaction($0, atIndex: index) }
    }

    func metadataInTransactionAtIndex<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> Metadata? {
        return { self.metadataInTransaction(transaction, atIndex: $0) }
    }

    func metadataAtIndexesInTransaction<
        Indexes, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(indexes: Indexes) -> Database.Connection.ReadTransaction -> [Metadata] {
            return { indexes.flatMap(self.metadataInTransactionAtIndex($0)) }
    }

    /**
    Reads the metadata at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `Metadata`
    */
    public func metadataAtIndex<
        Metadata where
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(index: YapDB.Index) -> Metadata? {
        return sync(metadataAtIndexInTransaction(index))
    }

    /**
    Reads the metadata at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `Metadata`
    */
    public func metadataAtIndexes<
        Indexes, Metadata where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.ValueType == Metadata>(indexes: Indexes) -> [Metadata] {
            return sync(metadataAtIndexesInTransaction(indexes))
    }
}
