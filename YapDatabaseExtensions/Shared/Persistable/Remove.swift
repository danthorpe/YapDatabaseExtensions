//
//  Created by Daniel Thorpe on 22/04/2015.
//
//

import Foundation
import YapDatabase

public protocol Removable {
    typealias Database: DatabaseType

    var indexes: [YapDB.Index] { get }
}

/**
Remove wrapper for an array of indexes. This type facilitates
the removal of items from YapDatabase.

This wrapper does not impose any constraints on the type of
item that it stores. However, the APIs which are available
to this wrapped structure will only be available if your
model types implement the correct protocols to facilitate
writing to YapDatabase.
*/
public struct Remove<D: DatabaseType>: Removable {

    public typealias Database = D

    /// The items which will be written into the database.
    public let indexes: [YapDB.Index]

    init(_ index: YapDB.Index) {
        indexes = [index]
    }

    init<Indexes where Indexes: SequenceType, Indexes.Generator.Element == YapDB.Index>(_ items: Indexes) {
        indexes = Array(items)
    }

    init<Item where Item: Persistable>(_ item: Item) {
        indexes = [item.index]
    }

    init<Items where Items: SequenceType, Items.Generator.Element: Persistable>(_ items: Items) {
        indexes = items.map { $0.index }
    }
}

extension Persistable {

    /**
    Returns a type suitable for *removing* an instance of the
    receiver from the database, when you only have the index. In
    other words, you don't need to read the object if you just
    want to remove it - use the static functions on its type.

    For example, given a `Person` key, inside a read write
    transaction, you can remove the object like this:

        Person.remove(index).on(transaction)

    Alternatively, given a `YapDatabaseConnection`, you can
    synchronously write the object to the database as:

        Person.remove(index).sync(connection)

    and asynchronously:

        Person.remove(index).async(connection) {
            print("did remove person")
        }

    Finally, if you use `NSOperation`, you can do:

        queue.addOperation(Person.remove(index).operation(connection))

    - returns: a `Remove` value composing the receiver.
    */
    public static func remove(index: YapDB.Index) -> Remove<YapDatabase> {
        return Remove(index)
    }

    /**
    Returns a type suitable for *removing* an instance of the
    receiver from the database, when you only have the key. In
    other words, you don't need to read the object if you just
    want to remove it - use the static functions on its type.

    For example, given a `Person` key, inside a read write
    transaction, you can remove the object like this:

    Person.remove(key).on(transaction)

    Alternatively, given a `YapDatabaseConnection`, you can
    synchronously write the object to the database as:

        Person.remove(key).sync(connection)

    and asynchronously:

        Person.remove(key).async(connection) {
            print("did remove person")
        }

    Finally, if you use `NSOperation`, you can do:

        queue.addOperation(Person.remove(key).operation(connection))

    - returns: a `Remove` value composing the receiver.
    */
    public static func remove(key: String) -> Remove<YapDatabase> {
        return remove(indexWithKey(key))
    }

    /**
    Returns a type suitable for *removing* the receiver from the
    database.

    For example, given a `Person` object, inside a read write
    transaction, you can remove the object like this:

        person.remove.on(transaction)

    Alternatively, given a `YapDatabaseConnection`, you can
    synchronously write the object to the database as:

        person.remove.sync(connection)

    and asynchronously:

        person.remove.async(connection)

    Finally, if you use `NSOperation`, you can do:

        queue.addOperation(person.remove.operation(connection))

    - returns: a `Remove` value composing the receiver.
    */
    public var remove: Remove<YapDatabase> {
        return Remove(self)
    }
}

extension SequenceType where Generator.Element: Persistable {

    /**
    Returns a type suitable for *removing* the receiver from the
    database.

    For example, given a sequence of `Person` objects, inside
    a read write transaction, you can remove all the objects to
    the database like this:

        people.remove.on(transaction)

    Alternatively, given a `YapDatabaseConnection`, you can
    synchronously write all the objects to the database as, in
    the same transaction like this:

        people.remove.sync(connection)

    and asynchronously:

        people.remove.async(connection)

    Finally, if you use `NSOperation`, you can do:

        queue.addOperation(people.remove.operation(connection))

    - returns: a `Remove` value composing the receiver.
    */
    public var remove: Remove<YapDatabase> {
        return Remove(self)
    }
}

extension SequenceType where Generator.Element == YapDB.Index {

    /**
    Returns a type suitable for *removing* the items referenced
    by the receiver from the database. In other words, you've got
    an array of database indexes to remove.

    For example, given a sequence of `YapDB.Index` values, inside
    a read write transaction, you can remove all the objects to
    the database like this:

        indexes.remove.on(transaction)

    Alternatively, given a `YapDatabaseConnection`, you can
    synchronously write all the objects to the database as, in
    the same transaction like this:

        indexes.remove.sync(connection)

    and asynchronously:

        indexes.remove.async(connection)

    Finally, if you use `NSOperation`, you can do:

        indexes.addOperation(people.remove.operation(connection))

    - returns: a `Remove` value composing the receiver.
    */
    public var remove: Remove<YapDatabase> {
        return Remove(self)
    }
}


// MARK: - Objects with no Metadata

extension Removable {

    /**
    Remove the items at indexes using an existing transaction.

    - parameter transaction: a YapDatabaseReadWriteTransaction
    */
    public func on(transaction: Database.Connection.WriteTransaction) {
        transaction.removeAtIndexes(indexes)
    }

    /**
    Remove the items at indexes synchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func sync(connection: Database.Connection) {
        connection.write(on)
    }

    /**
    Remove the items at indexes asynchronously using a connection.

    - parameter connection: a YapDatabaseConnection
    */
    public func async(connection: Database.Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t) {
        connection.asyncWrite(on, queue: queue, completion: completion)
    }

    /**
    Remove the items at indexes inside of an `NSOperation`.

    - parameter connection: a YapDatabaseConnection
    */
    public func operation(connection: Database.Connection) -> NSOperation {
        return connection.writeBlockOperation { self.on($0) }
    }
}














