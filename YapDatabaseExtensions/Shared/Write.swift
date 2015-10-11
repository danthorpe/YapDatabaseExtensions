//
//  Created by Daniel Thorpe on 22/04/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Writable

/// Generic protocol for Writer types.
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
    and `ValueCoding`.
    
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
    and `ValueCoding`.

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

