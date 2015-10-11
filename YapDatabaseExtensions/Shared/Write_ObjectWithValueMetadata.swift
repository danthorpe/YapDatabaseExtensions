//
//  Write_ObjectWithValueMetadata.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 11/10/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Objects with Value Metadata

extension Writable where
    ItemType: NSCoding,
    ItemType: MetadataPersistable,
    ItemType.MetadataType: ValueCoding,
    ItemType.MetadataType.Coder: NSCoding,
    ItemType.MetadataType.Coder.ValueType == ItemType.MetadataType {

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

// MARK: - Object with Value metadata

extension WriteTransactionType {

    /**
    Write the item to the database using the transaction.
    
    - parameter item: the item to store.
    */
    public func write<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(item: ObjectWithValueMetadata) {
            writeAtIndex(item.index, object: item, metadata: item.metadata?.encoded)
    }

    /**
    Write the items to the database using the transaction.
    
    - parameter items: an array of items to store.
    */
    public func write<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(items: [ObjectWithValueMetadata]) {
            items.forEach(write)
    }
}

extension ConnectionType {

    /**
    Write the item to the database synchronously using the connection in a new transaction.
    
    - parameter item: the item to store.
    */
    public func write<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(item: ObjectWithValueMetadata) {
            write { $0.write(item) }
    }

    /**
    Write the items to the database synchronously using the connection in a new transaction.
    
    - parameter items: an array of items to store.
    */
    public func write<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(items: [ObjectWithValueMetadata]) {
            write { $0.write(items) }
    }

    /**
    Write the item to the database asynchronously using the connection in a new transaction.
    
    - parameter item: the item to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(item: ObjectWithValueMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: { _ in completion() })
    }

    /**
    Write the items to the database asynchronously using the connection in a new transaction.
    
    - parameter items: an array of items to store.
    - parameter queue: the dispatch_queue_t to run the completion block on.
    - parameter completion: a dispatch_block_t for completion.
    */
    public func asyncWrite<
        ObjectWithValueMetadata where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(items: [ObjectWithValueMetadata], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: { _ in completion() })
    }
}




