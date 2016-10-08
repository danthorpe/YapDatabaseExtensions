//
//  Functional_Remove.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 12/10/2015.
//
//

import Foundation

extension WriteTransactionType {

    /**
    Removes an item from the database using the write transaction.
    
    - parameter item: a `Persistable` item
    */
    public func remove<Item: Persistable>(item: Item) {
        removeAtIndexes([item.index])
    }

    /**
    Removes items from the database using the write transaction.

    - parameter items: a sequence of `Persistable` items
    */
    public func remove<
        Items, Item where
        Items: SequenceType,
        Items.Generator.Element == Item,
        Item: Persistable>(items: Items) {
            removeAtIndexes(items.map { $0.index })
    }
}

extension ConnectionType {

    /**
    Removes an item from the database synchronously using a 
    new transaction in this connection.

    - parameter item: a `Persistable` item
    */
    public func remove<Item: Persistable>(item: Item) {
        write { $0.remove(item) }
    }

    /**
    Removes items from the database synchronously using a
    new transaction in this connection.

    - parameter items: a sequence of `Persistable` items
    */
    public func remove<
        Items, Item where
        Items: SequenceType,
        Items.Generator.Element == Item,
        Item: Persistable>(items: Items) {
            write { $0.remove(items) }
    }

    /**
    Removes an item from the database asynchronously using a
    new transaction in this connection.

    - parameter item: a `Persistable` item
    */
    public func asyncRemove<Item: Persistable>(item: Item, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t? = .None) {
        asyncWrite({ $0.remove(item) }, queue: queue, completion: { _ in completion?() })
    }

    /**
    Removes items from the database asynchronously using a
    new transaction in this connection.

    - parameter items: a sequence of `Persistable` items
    */
    public func asyncRemove<
        Items, Item where
        Items: SequenceType,
        Items.Generator.Element == Item,
        Item: Persistable>(items: Items, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: dispatch_block_t? = .None) {
            asyncWrite({ $0.remove(items) }, queue: queue, completion: { _ in completion?() })
    }
}
