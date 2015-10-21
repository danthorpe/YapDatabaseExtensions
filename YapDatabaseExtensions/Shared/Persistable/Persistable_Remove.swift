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
    public func remove<WriteTransaction: WriteTransactionType>(transaction: WriteTransaction) {
        transaction.remove(self)
    }

    /**
    Removes the receiver synchronously using a new transaction with the connection

    - parameter connection: a `ConnectionType` connection
    */
    public func remove<Connection: ConnectionType>(connection: Connection) {
        connection.remove(self)
    }

    /**
    Removes the receiver synchronously using a new transaction with the connection

    - parameter connection: a `ConnectionType` connection
    */
    public func asyncRemove<Connection: ConnectionType>(connection: Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t? = .None) {
        connection.asyncRemove(self, queue: queue, completion: completion)
    }

    /**
    Returns an `NSOperation` which will remove the receiver synchronously using a 
    new transaction with the connection when it is executed.

    - parameter connection: a `ConnectionType` connection
    */
    public func removeOperation<Connection: ConnectionType>(connection: Connection) -> NSOperation {
        return NSBlockOperation { connection.remove(self) }
    }
}

extension SequenceType where
Generator.Element: Persistable {

    /**
    Removes the receiver using the write transaction.

    - parameter transaction: a `WriteTransactionType` transaction
    */
    public func remove<WriteTransaction: WriteTransactionType>(transaction: WriteTransaction) {
        transaction.remove(self)
    }

    /**
    Removes the receiver synchronously using a new transaction with the connection

    - parameter connection: a `ConnectionType` connection
    */
    public func remove<Connection: ConnectionType>(connection: Connection) {
        connection.remove(self)
    }

    /**
    Removes the receiver synchronously using a new transaction with the connection

    - parameter connection: a `ConnectionType` connection
    */
    public func asyncRemove<Connection: ConnectionType>(connection: Connection, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t? = .None) {
        connection.asyncRemove(self, queue: queue, completion: completion)
    }

    /**
    Returns an `NSOperation` which will remove the receiver synchronously using a
    new transaction with the connection when it is executed.

    - parameter connection: a `ConnectionType` connection
    */
    public func removeOperation<Connection: ConnectionType>(connection: Connection) -> NSOperation {
        return NSBlockOperation { connection.remove(self) }
    }
}

