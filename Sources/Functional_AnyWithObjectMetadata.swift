//
//  Functional_AnyWithObjectMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 13/10/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Reading

extension ReadTransactionType {

    /**
    Reads the metadata at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `MetadataType`
    */
    public func readMetadataAtIndex<
        MetadataType: NSCoding>(_ index: YapDB.Index) -> MetadataType? {
            return readMetadataAtIndex(index) as? MetadataType
    }

    /**
    Reads the metadata at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `MetadataType`
    */
    public func readMetadataAtIndexes<
        Indexes, MetadataType>(_ indexes: Indexes) -> [MetadataType?] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        MetadataType: NSCoding {
            return indexes.map(readMetadataAtIndex)
    }
}

extension ConnectionType {

    /**
    Reads the metadata at a given index.

    - parameter index: a YapDB.Index
    - returns: an optional `MetadataType`
    */
    public func readMetadataAtIndex<
        MetadataType: NSCoding>(_ index: YapDB.Index) -> MetadataType? {
            return read { $0.readMetadataAtIndex(index) }
    }

    /**
    Reads the metadata at the indexes.

    - parameter indexes: a SequenceType of YapDB.Index values
    - returns: an array of `MetadataType`
    */
    public func readMetadataAtIndexes<
        Indexes, MetadataType>(_ indexes: Indexes) -> [MetadataType?] where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index,
        MetadataType: NSCoding {
            return read { $0.readMetadataAtIndexes(indexes) }
    }
}

