//
//  Curried_ObjectWithNoMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 14/10/2015.
//
//

import Foundation
import ValueCoding

// MARK: - Persistable

extension Persistable where
    Self: NSCoding,
    Self.MetadataType == Void {

    /**
    Returns a closure which, given a read transaction will return
    the item at the given index.
    
    - parameter index: a YapDB.Index
    - returns: a (ReadTransaction) -> Self? closure.
    */
    public static func readAtIndex<
        ReadTransaction where
        ReadTransaction: ReadTransactionType>(index: YapDB.Index) -> ReadTransaction -> Self? {
            return { $0.readAtIndex(index) }
    }

    /**
    Returns a closure which, given a read transaction will return
    the items at the given indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: a (ReadTransaction) -> [Self] closure.
    */
    public static func readAtIndexes<
        Indexes, ReadTransaction where
        Indexes: SequenceType,
        Indexes.Generator.Element == YapDB.Index,
        ReadTransaction: ReadTransactionType>(indexes: Indexes) -> ReadTransaction -> [Self] {
            return { $0.readAtIndexes(indexes) }
    }

    /**
    Returns a closure which, given a read transaction will return
    the item at the given key.

    - parameter key: a String
    - returns: a (ReadTransaction) -> Self? closure.
    */
    public static func readByKey<
        ReadTransaction where
        ReadTransaction: ReadTransactionType>(key: String) -> ReadTransaction -> Self? {
            return { $0.readByKey(key) }
    }

    /**
    Returns a closure which, given a read transaction will return
    the items at the given keys.

    - parameter keys: a SequenceType of String values
    - returns: a (ReadTransaction) -> [Self] closure.
    */
    public static func readByKeys<
        Keys, ReadTransaction where
        Keys: SequenceType,
        Keys.Generator.Element == String,
        ReadTransaction: ReadTransactionType>(keys: Keys) -> ReadTransaction -> [Self] {
            return  { $0.readAtIndexes(Self.indexesWithKeys(keys)) }
    }

    /**
    Returns a closure which, given a write transaction will write
    and return the item.
    
    - warning: Be aware that this will capure `self`.
    - returns: a (WriteTransaction) -> Self closure
    */
    public func writeOn<WriteTransaction: WriteTransactionType>() -> WriteTransaction -> Self {
        return { $0.write(self) }
    }
}
