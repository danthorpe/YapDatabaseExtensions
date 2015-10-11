//
//  Write_ObjectWithObjectMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 11/10/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Objects with Object Metadata

extension Writable
    where
    ItemType: NSCoding,
    ItemType: MetadataPersistable,
    ItemType.MetadataType: NSCoding {

    /**
    Write the items using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    */
    public func on(transaction: Database.Connection.WriteTransaction) {
        transaction.write(items)
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func sync(connection: Database.Connection) {
        connection.write(on)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func async(connection: Database.Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
        connection.asyncWrite(on, queue: queue, completion: completion)
    }

    /**
    Write the items inside of an `NSOperation`.

    - parameter connection: a YapDatabaseConnection
    */
    public func operation(connection: Database.Connection) -> NSOperation {
        return connection.writeBlockOperation { self.on($0) }
    }
}

// MARK: - Object with Object metadata

extension WriteTransactionType {

    public func write<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(item: ObjectWithObjectMetadata) {
            writeAtIndex(item.index, object: item, metadata: item.metadata)
    }

    public func write<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(items: [ObjectWithObjectMetadata]) {
            items.forEach(write)
    }
}

extension ConnectionType {

    public func write<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(item: ObjectWithObjectMetadata) {
            write { $0.write(item) }
    }

    public func write<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(items: [ObjectWithObjectMetadata]) {
            write { $0.write(items) }
    }

    public func asyncWrite<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(item: ObjectWithObjectMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: { _ in completion() })
    }

    public func asyncWrite<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(items: [ObjectWithObjectMetadata], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: { _ in completion() })
    }
}



