//
//  Created by Daniel Thorpe on 22/04/2015.
//
//

import Foundation

extension Persistable {

    /**
    Removes the receiver using the write transaction.

    - parameter transaction: a `WriteTransactionType` transaction
    */
    public func remove<WriteTransaction: WriteTransactionType>(_ transaction: WriteTransaction) {
        transaction.remove(self)
    }

    /**
    Removes the receiver synchronously using a new transaction with the connection

    - parameter connection: a `ConnectionType` connection
    */
    public func remove<Connection: ConnectionType>(_ connection: Connection) {
        connection.remove(self)
    }

    /**
    Removes the receiver synchronously using a new transaction with the connection

    - parameter connection: a `ConnectionType` connection
    */
    public func asyncRemove<Connection: ConnectionType>(_ connection: Connection, queue: DispatchQueue = DispatchQueue.main, completion: ()->()? = .none) {
        connection.asyncRemove(self, queue: queue, completion: completion)
    }

    /**
    Returns an `NSOperation` which will remove the receiver synchronously using a 
    new transaction with the connection when it is executed.

    - parameter connection: a `ConnectionType` connection
    */
    public func removeOperation<Connection: ConnectionType>(_ connection: Connection) -> Operation {
        return BlockOperation { connection.remove(self) }
    }
}

extension Sequence where
Iterator.Element: Persistable {

    /**
    Removes the receiver using the write transaction.

    - parameter transaction: a `WriteTransactionType` transaction
    */
    public func remove<WriteTransaction: WriteTransactionType>(_ transaction: WriteTransaction) {
        transaction.remove(self)
    }

    /**
    Removes the receiver synchronously using a new transaction with the connection

    - parameter connection: a `ConnectionType` connection
    */
    public func remove<Connection: ConnectionType>(_ connection: Connection) {
        connection.remove(self)
    }

    /**
    Removes the receiver synchronously using a new transaction with the connection

    - parameter connection: a `ConnectionType` connection
    */
    public func asyncRemove<Connection: ConnectionType>(_ connection: Connection, queue: DispatchQueue = DispatchQueue.main, completion: ()->()? = .none) {
        connection.asyncRemove(self, queue: queue, completion: completion)
    }

    /**
    Returns an `NSOperation` which will remove the receiver synchronously using a
    new transaction with the connection when it is executed.

    - parameter connection: a `ConnectionType` connection
    */
    public func removeOperation<Connection: ConnectionType>(_ connection: Connection) -> Operation {
        return BlockOperation { connection.remove(self) }
    }
}

