//
//  Created by Daniel Thorpe on 22/04/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Readable

/// Generic protocol for Reader types.
public protocol Readable {
    typealias ItemType
    typealias Database: DatabaseType

    var transaction: Database.Connection.ReadTransaction? { get }
    var connection: Database.Connection { get }
}

/// A generic structure used to read from a database type.
public struct Read<Item, D: DatabaseType>: Readable {
    public typealias ItemType = Item
    public typealias Database = D

    let reader: Handle<D>

    public var transaction: D.Connection.ReadTransaction? {
        if case let .Transaction(transaction) = reader {
            return transaction
        }
        return .None
    }

    public var connection: D.Connection {
        switch reader {
        case .Transaction(_):
            fatalError("Attempting to get connection from a transaction.")
        case .Connection(let connection):
            return connection
        default:
            return database.makeNewConnection()
        }
    }

    internal var database: D {
        if case let .Database(database) = reader {
            return database
        }
        fatalError("Attempting to get database from \(reader)")
    }

    internal init(_ transaction: D.Connection.ReadTransaction) {
        reader = .Transaction(transaction)
    }

    internal init(_ connection: D.Connection) {
        reader = .Connection(connection)
    }

    internal init(_ database: D) {
        reader = .Database(database)
    }
}

extension Persistable {

    /**
    Returns a type suitable for *reading* from the transaction. The available
    functions will depend on your own types correctly implementing Persistable,
    MetadataPersistable and ValueCoding.
    
    For example, given the key for a `Person` type, and you are in a read
    transaction block, the following would read the object for you.
    
        if let person = Person.read(transaction).key(key) {
            print("Hello \(person.name)")
        }
    
    Note that this API is consistent for Object types, Value types, with or
    without metadata.
    
    - parameter transaction: a type conforming to ReadTransactionType such as
    YapDatabaseReadTransaction
    */
    public static func read(transaction: YapDatabaseReadTransaction) -> Read<Self, YapDatabase> {
        return Read(transaction)
    }

    /**
    Returns a type suitable for Reading from a database connection. The available
    functions will depend on your own types correctly implementing Persistable,
    MetadataPersistable and ValueCoding.

    For example, given the key for a `Person` type, and you have a database 
    connection.

        if let person = Person.read(connection).key(key) {
            print("Hello \(person.name)")
        }

    Note that this API is consistent for Object types, Value types, with or
    without metadata.

    - parameter connection: a type conforming to ConnectionType such as
    YapDatabaseConnection.
    */
    public static func read(connection: YapDatabaseConnection) -> Read<Self, YapDatabase> {
        return Read(connection)
    }

    internal static func read(database: YapDatabase) -> Read<Self, YapDatabase> {
        return Read(database)
    }
}

extension Readable
    where
    ItemType: Persistable {

    func sync<T>(block: (Database.Connection.ReadTransaction) -> T) -> T {
        if let transaction = transaction {
            return block(transaction)
        }
        return connection.read(block)
    }
}





