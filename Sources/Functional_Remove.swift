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
    public func remove<Item: Persistable>(_ item: Item) {
        removeAtIndexes([item.index])
    }

    /**
    Removes items from the database using the write transaction.

    - parameter items: a sequence of `Persistable` items
    */
    public func remove<
        Items, Item>(_ items: Items) where
        Items: Sequence,
        Items.Iterator.Element == Item,
        Item: Persistable {
            removeAtIndexes(items.map { $0.index })
    }
}

extension ConnectionType {

    /**
    Removes an item from the database synchronously using a 
    new transaction in this connection.

    - parameter item: a `Persistable` item
    */
    public func remove<Item: Persistable>(_ item: Item) {
        write { $0.remove(item) }
    }

    /**
    Removes items from the database synchronously using a
    new transaction in this connection.

    - parameter items: a sequence of `Persistable` items
    */
    public func remove<
        Items, Item>(_ items: Items) where
        Items: Sequence,
        Items.Iterator.Element == Item,
        Item: Persistable {
            write { $0.remove(items) }
    }

    /**
    Removes an item from the database asynchronously using a
    new transaction in this connection.

    - parameter item: a `Persistable` item
    */
    public func asyncRemove<Item: Persistable>(_ item: Item, queue: DispatchQueue = DispatchQueue.main, completion: @escaping ()->()? = .none) {
        asyncWrite({ $0.remove(item) }, queue: queue, completion: { _ in completion() })
    }

    /**
    Removes items from the database asynchronously using a
    new transaction in this connection.

    - parameter items: a sequence of `Persistable` items
    */
    public func asyncRemove<
        Items, Item>(_ items: Items, queue: DispatchQueue = DispatchQueue.main, completion: @escaping ()->()? = .none) where
        Items: Sequence,
        Items.Iterator.Element == Item,
        Item: Persistable {
            asyncWrite({ $0.remove(items) }, queue: queue, completion: { _ in completion() })
    }
}
