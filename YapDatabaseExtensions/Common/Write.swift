//
//  Created by Daniel Thorpe on 22/04/2015.
//
//

import YapDatabase

// MARK: - YapDatabaseTransaction

extension YapDatabaseReadWriteTransaction: WriteTransactionType {

    public func writeAtIndex(index: YapDB.Index, object: AnyObject, metadata: AnyObject? = .None) {
        if let metadata: AnyObject = metadata {
            setObject(object, forKey: index.key, inCollection: index.collection, withMetadata: metadata)
        }
        else {
            setObject(object, forKey: index.key, inCollection: index.collection)
        }
    }
}

// MARK: - Writable

public protocol Writable {
    typealias ItemType
    typealias Connection: ConnectionType

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
public struct Write<Item, C: ConnectionType>: Writable {

    public typealias Connection = C

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
    database. The available functions will depend on the receive
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
    public var write: Write<Self, YapDatabaseConnection> {
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
    a read write transaction, you can write all the object to
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
    public var write: Write<Generator.Element, YapDatabaseConnection> {
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
    public func on(transaction: Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0, metadata: .None) }
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func sync(connection: Connection) {
        connection.write(on)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func async(connection: Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
        connection.asyncWrite(on, queue: queue, completion: completion)
    }

    /**
    Write the items inside of an `NSOperation`.

    - parameter connection: a YapDatabaseConnection
    */
    public func operation(connection: Connection) -> NSOperation {
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
    public func on(transaction: Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0, metadata: $0.metadata) }
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func sync(connection: Connection) {
        connection.write(on)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func async(connection: Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
        connection.asyncWrite(on, queue: queue, completion: completion)
    }

    /**
    Write the items inside of an `NSOperation`.

    - parameter connection: a YapDatabaseConnection
    */
    public func operation(connection: Connection) -> NSOperation {
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
    public func on(transaction: Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0, metadata: $0.metadata?.archive) }
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func sync(connection: Connection) {
        connection.write(on)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func async(connection: Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
        connection.asyncWrite(on, queue: queue, completion: completion)
    }

    /**
    Write the items inside of an `NSOperation`.

    - parameter connection: a YapDatabaseConnection
    */
    public func operation(connection: Connection) -> NSOperation {
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
    public func on(transaction: Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0.archive, metadata: .None) }
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func sync(connection: Connection) {
        connection.write(on)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func async(connection: Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
        connection.asyncWrite(on, queue: queue, completion: completion)
    }

    /**
    Write the items inside of an `NSOperation`.

    - parameter connection: a YapDatabaseConnection
    */
    public func operation(connection: Connection) -> NSOperation {
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
    public func on(transaction: Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0.archive, metadata: $0.metadata) }
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func sync(connection: Connection) {
        connection.write(on)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func async(connection: Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
        connection.asyncWrite(on, queue: queue, completion: completion)
    }

    /**
    Write the items inside of an `NSOperation`.

    - parameter connection: a YapDatabaseConnection
    */
    public func operation(connection: Connection) -> NSOperation {
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
    public func on(transaction: Connection.WriteTransaction) {
        items.forEach { transaction.writeAtIndex($0.index, object: $0.archive, metadata: $0.metadata?.archive) }
    }

    /**
    Write the items synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func sync(connection: Connection) {
        connection.write(on)
    }

    /**
    Write the items asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func async(connection: Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
        connection.asyncWrite(on, queue: queue, completion: completion)
    }

    /**
    Write the items inside of an `NSOperation`.

    - parameter connection: a YapDatabaseConnection
    */
    public func operation(connection: Connection) -> NSOperation {
        return connection.writeBlockOperation { self.on($0) }
    }
}




