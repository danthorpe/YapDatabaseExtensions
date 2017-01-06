//
//  Curried_ValueWithValueMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 14/10/2015.
//
//

import Foundation
import ValueCoding

// MARK: - Persistable

extension Persistable where
    Self: ValueCoding,
    Self.Coder: NSCoding,
    Self.Coder.Value == Self {

    /**
    Returns a closure which, given a read transaction will return
    the item at the given index.
    
    - parameter index: a YapDB.Index
    - returns: a (ReadTransaction) -> Self? closure.
    */
    public static func readWithMetadataAtIndex<
        ReadTransaction, Metadata>(_ index: YapDB.Index) -> (ReadTransaction) -> YapItem<Self, Metadata>? where
        ReadTransaction: ReadTransactionType,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
        return { $0.readWithMetadataAtIndex(index) }
    }

    /**
    Returns a closure which, given a read transaction will return
    the items at the given indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: a (ReadTransaction) -> [Self] closure.
    */
    public static func readWithMetadataAtIndexes<
        Indexes, ReadTransaction, Metadata>(_ indexes: Indexes) -> (ReadTransaction) -> [YapItem<Self, Metadata>?] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        ReadTransaction: ReadTransactionType,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
        return { $0.readWithMetadataAtIndexes(indexes) }
    }

    /**
    Returns a closure which, given a read transaction will return
    the item at the given key.

    - parameter key: a String
    - returns: a (ReadTransaction) -> Self? closure.
    */
    public static func readWithMetadataByKey<
        ReadTransaction, Metadata>(_ key: String) -> (ReadTransaction) -> YapItem<Self, Metadata>? where
        ReadTransaction: ReadTransactionType,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
        return { $0.readWithMetadataByKey(key) }
    }

    /**
    Returns a closure which, given a read transaction will return
    the items at the given keys.

    - parameter keys: a SequenceType of String values
    - returns: a (ReadTransaction) -> [Self] closure.
    */
    public static func readWithMetadataByKeys<
        Keys, ReadTransaction, Metadata>(_ keys: Keys) -> (ReadTransaction) -> [YapItem<Self, Metadata>?] where
        Keys: Sequence,
        Keys.Iterator.Element == String,
        ReadTransaction: ReadTransactionType,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
        return  { $0.readWithMetadataAtIndexes(Self.indexesWithKeys(keys)) }
    }

    /**
    Returns a closure which, given a write transaction will write
    and return the item.
    
    - warning: Be aware that this will capure `self`.
    - returns: a (WriteTransaction) -> Self closure
    */
    public func writeWithMetadata<
        WriteTransaction, Metadata>(_ metadata: Metadata? = nil) -> (WriteTransaction) -> YapItem<Self, Metadata> where
        WriteTransaction: WriteTransactionType,
        Metadata: ValueCoding,
        Metadata.Coder: NSCoding,
        Metadata.Coder.Value == Metadata {
        return { $0.writeWithMetadata(YapItem(self, metadata)) }
    }
}
