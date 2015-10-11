//
//  Created by Daniel Thorpe on 22/04/2015.
//
//

import Foundation
import YapDatabase

// MARK: - Writable

public protocol Writable {
    typealias ItemType
    typealias Database: DatabaseType

    var items: [ItemType] { get }
}

/**
Write wrapper for an array of items. This type facilitates
writing of items to YapDatabase.

This wrapper does not impose any constraints on the type of
item that it stores. However, the APIs which are available
to this wrapped structure will only be available if your
model types implement the correct protocols to facilitate
writing to YapDatabase.
*/
public struct Write<Item, D: DatabaseType>: Writable {

    public typealias Database = D

    /// The items which will be written into the database.
    public let items: [Item]

    init(_ element: Item) {
        items = [element]
    }

    init<Items where Items: SequenceType, Items.Generator.Element == Item>(_ elements: Items) {
        items = Array(elements)
    }
}

extension Persistable {

    /**
    Returns a type suitable for *writing* the receiver to the 
    database. The available functions will depend on the receiver
    correctly implementing `Persistable`, `MetadataPersistable` 
    and `Saveable`.
    
    For example, given a `Person` object, inside a read write
    transaction, you can write the object like this:
    
        person.write.on(transaction)

    Alternatively, given a `YapDatabaseConnection`, you can 
    synchronously write the object to the database as:
    
        person.write.sync(connection)
    
    and asynchronously:
    
        person.write.async(connection)
    
    Finally, if you use `NSOperation`, you can do:
    
        queue.addOperation(person.write.operation(connection))

    - returns: a `Write` value composing the receiver.
    */
    public var write: Write<Self, YapDatabase> {
        return Write(self)
    }
}

extension SequenceType where Generator.Element: Persistable {

    /**
    Returns a type suitable for *writing* the receiver to the
    database. The available functions will depend on the receive
    correctly implementing `Persistable`, `MetadataPersistable`
    and `Saveable`.

    For example, given a sequence of `Person` objects, inside 
    a read write transaction, you can write all the objects to
    the database like this:

        people.write.on(transaction)

    Alternatively, given a `YapDatabaseConnection`, you can
    synchronously write all the objects to the database as, in
    the same transaction like this:

        people.write.sync(connection)

    and asynchronously:

        people.write.async(connection)

    Finally, if you use `NSOperation`, you can do:

        queue.addOperation(people.write.operation(connection))

    - returns: a `Write` value composing the receiver.
    */
    public var write: Write<Generator.Element, YapDatabase> {
        return Write(self)
    }
}

// MARK: - Objects with no Metadata

extension Writable
    where
    ItemType: NSCoding,
    ItemType: Persistable {

    /**
    Write the items using an existing transaction.
    
    - parameter transaction: a YapDatabaseReadWriteTransaction
    */
    public func on(transaction: Database.Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0, metadata: .None) }
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
        items.forEach { transaction.writeAtIndex($0.index, object: $0, metadata: $0.metadata) }
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

// MARK: - Objects with Value Metadata

extension Writable
    where
    ItemType: NSCoding,
    ItemType: MetadataPersistable,
    ItemType.MetadataType: Saveable,
    ItemType.MetadataType.ArchiverType: NSCoding,
    ItemType.MetadataType.ArchiverType.ValueType == ItemType.MetadataType {

    /**
    Write the items using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    */
    public func on(transaction: Database.Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0, metadata: $0.metadata?.archive) }
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

// MARK: - Values with no Metadata

extension Writable
    where
    ItemType: Saveable,
    ItemType: Persistable,
    ItemType.ArchiverType: NSCoding,
    ItemType.ArchiverType.ValueType == ItemType {

    /**
    Write the items using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    */
    public func on(transaction: Database.Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0.archive, metadata: .None) }
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

// MARK: - Values with Object Metadata

extension Writable
    where
    ItemType: Saveable,
    ItemType: MetadataPersistable,
    ItemType.ArchiverType: NSCoding,
    ItemType.ArchiverType.ValueType == ItemType,
    ItemType.MetadataType: NSCoding {

    /**
    Write the items using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    */
    public func on(transaction: Database.Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0.archive, metadata: $0.metadata) }
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

// MARK: - Values with Value Metadata

extension Writable
    where
    ItemType: Saveable,
    ItemType: MetadataPersistable,
    ItemType.ArchiverType: NSCoding,
    ItemType.ArchiverType.ValueType == ItemType,
    ItemType.MetadataType: Saveable,
    ItemType.MetadataType.ArchiverType: NSCoding,
    ItemType.MetadataType.ArchiverType.ValueType == ItemType.MetadataType {

    /**
    Write the items using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    */
    public func on(transaction: Database.Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0.archive, metadata: $0.metadata?.archive) }
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

// MARK: - Object with Value metadata

extension WriteTransactionType {

    public func write<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: Saveable,
        ObjectWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ObjectWithValueMetadata.MetadataType.ArchiverType.ValueType == ObjectWithValueMetadata.MetadataType>(item: ObjectWithValueMetadata) {
            writeAtIndex(item.index, object: item, metadata: item.metadata?.archive)
    }

    public func write<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: Saveable,
        ObjectWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ObjectWithValueMetadata.MetadataType.ArchiverType.ValueType == ObjectWithValueMetadata.MetadataType>(items: [ObjectWithValueMetadata]) {
            items.forEach(write)
    }
}

extension ConnectionType {

    public func write<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: Saveable,
        ObjectWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ObjectWithValueMetadata.MetadataType.ArchiverType.ValueType == ObjectWithValueMetadata.MetadataType>(item: ObjectWithValueMetadata) {
            write { $0.write(item) }
    }

    public func write<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: Saveable,
        ObjectWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ObjectWithValueMetadata.MetadataType.ArchiverType.ValueType == ObjectWithValueMetadata.MetadataType>(items: [ObjectWithValueMetadata]) {
            write { $0.write(items) }
    }

    public func asyncWrite<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: Saveable,
        ObjectWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ObjectWithValueMetadata.MetadataType.ArchiverType.ValueType == ObjectWithValueMetadata.MetadataType>(item: ObjectWithValueMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: { _ in completion() })
    }

    public func asyncWrite<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: Saveable,
        ObjectWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ObjectWithValueMetadata.MetadataType.ArchiverType.ValueType == ObjectWithValueMetadata.MetadataType>(items: [ObjectWithValueMetadata], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: { _ in completion() })
    }
}

// MARK: - Value with Object metadata

extension WriteTransactionType {

    public func write<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: Saveable,
        ValueWithObjectMetadata.ArchiverType: NSCoding,
        ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(item: ValueWithObjectMetadata) {
            writeAtIndex(item.index, object: item.archive, metadata: item.metadata)
    }

    public func write<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: Saveable,
        ValueWithObjectMetadata.ArchiverType: NSCoding,
        ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(items: [ValueWithObjectMetadata]) {
            items.forEach(write)
    }
}

extension ConnectionType {

    public func write<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: Saveable,
        ValueWithObjectMetadata.ArchiverType: NSCoding,
        ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(item: ValueWithObjectMetadata) {
            write { $0.write(item) }
    }

    public func write<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: Saveable,
        ValueWithObjectMetadata.ArchiverType: NSCoding,
        ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(items: [ValueWithObjectMetadata]) {
            write { $0.write(items) }
    }

    public func asyncWrite<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: Saveable,
        ValueWithObjectMetadata.ArchiverType: NSCoding,
        ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(item: ValueWithObjectMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: { _ in completion() })
    }

    public func asyncWrite<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: Saveable,
        ValueWithObjectMetadata.ArchiverType: NSCoding,
        ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(items: [ValueWithObjectMetadata], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: { _ in completion() })
    }
}

// MARK: - Value with Value metadata

extension WriteTransactionType {

    public func write<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: Saveable,
        ValueWithValueMetadata.ArchiverType: NSCoding,
        ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: Saveable,
        ValueWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ValueWithValueMetadata.MetadataType.ArchiverType.ValueType == ValueWithValueMetadata.MetadataType>(item: ValueWithValueMetadata) {
            writeAtIndex(item.index, object: item.archive, metadata: item.metadata?.archive)
    }

    public func write<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: Saveable,
        ValueWithValueMetadata.ArchiverType: NSCoding,
        ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: Saveable,
        ValueWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ValueWithValueMetadata.MetadataType.ArchiverType.ValueType == ValueWithValueMetadata.MetadataType>(items: [ValueWithValueMetadata]) {
            items.forEach(write)
    }
}

extension ConnectionType {

    public func write<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: Saveable,
        ValueWithValueMetadata.ArchiverType: NSCoding,
        ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: Saveable,
        ValueWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ValueWithValueMetadata.MetadataType.ArchiverType.ValueType == ValueWithValueMetadata.MetadataType>(item: ValueWithValueMetadata) {
            write { $0.write(item) }
    }

    public func write<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: Saveable,
        ValueWithValueMetadata.ArchiverType: NSCoding,
        ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: Saveable,
        ValueWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ValueWithValueMetadata.MetadataType.ArchiverType.ValueType == ValueWithValueMetadata.MetadataType>(items: [ValueWithValueMetadata]) {
            write { $0.write(items) }
    }

    public func asyncWrite<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: Saveable,
        ValueWithValueMetadata.ArchiverType: NSCoding,
        ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: Saveable,
        ValueWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ValueWithValueMetadata.MetadataType.ArchiverType.ValueType == ValueWithValueMetadata.MetadataType>(item: ValueWithValueMetadata, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(item) }, queue: queue, completion: { _ in completion() })
    }

    public func asyncWrite<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: Saveable,
        ValueWithValueMetadata.ArchiverType: NSCoding,
        ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: Saveable,
        ValueWithValueMetadata.MetadataType.ArchiverType: NSCoding,
        ValueWithValueMetadata.MetadataType.ArchiverType.ValueType == ValueWithValueMetadata.MetadataType>(items: [ValueWithValueMetadata], queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
            asyncWrite({ $0.write(items) }, queue: queue, completion: { _ in completion() })
    }
}




