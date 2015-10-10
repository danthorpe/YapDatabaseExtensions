//
//  ValueWithObjectMetadataTests.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 09/10/2015.
//  Copyright © 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import XCTest
@testable import YapDatabaseExtensions

class ValueWithObjectMetadataTests: XCTestCase {

    var item: Inventory!
    var index: YapDB.Index!
    var key: String!

    var items: [Inventory]!
    var indexes: [YapDB.Index]!
    var keys: [String]!

    var database: TestableDatabase!
    var connection: TestableConnection!
    var writeTransaction: TestableWriteTransaction!
    var readTransaction: TestableReadTransaction!

    var reader: Read<Inventory, TestableDatabase>!
    var writer: Write<Inventory, TestableDatabase>!

    var dispatchQueue: dispatch_queue_t!
    var operationQueue: NSOperationQueue!

    override func setUp() {
        super.setUp()
        createPersistables()
        index = item.index
        key = item.key

        indexes = items.map { $0.index }
        keys = items.map { $0.key }

        database = TestableDatabase()
        connection = TestableConnection()
        writeTransaction = TestableWriteTransaction()
        readTransaction = TestableReadTransaction()

        connection.readTransaction = readTransaction
        connection.writeTransaction = writeTransaction
        database.connection = connection

        dispatchQueue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)
        operationQueue = NSOperationQueue()
    }

    override func tearDown() {
        item = nil
        index = nil
        key = nil
        items = nil
        indexes = nil
        keys = nil

        database = nil
        connection = nil
        writeTransaction = nil
        readTransaction = nil
        dispatchQueue = nil
        operationQueue = nil
        super.tearDown()
    }

    func createPersistables() {
        let products = [
            Product(
                metadata: Product.Metadata(categoryIdentifier: 1),
                identifier: "vodka-123",
                name: "Belvidere",
                barcode: .UPCA(1, 2, 3, 4)
            ),
            Product(
                metadata: Product.Metadata(categoryIdentifier: 2),
                identifier: "gin-123",
                name: "Boxer Gin",
                barcode: .UPCA(5, 10, 15, 20)
                ),
            Product(
                metadata: Product.Metadata(categoryIdentifier: 3),
                identifier: "rum-123",
                name: "Mount Gay Rum",
                barcode: .UPCA(12, 24, 39, 48)
                ),
            Product(
                metadata: Product.Metadata(categoryIdentifier: 2),
                identifier: "gin-234",
                name: "Monkey 47",
                barcode: .UPCA(31, 62, 93, 124)
                )
            ]

        items = products.map { Inventory(product: $0, metadata: NSNumber(integer: 12)) }
        item = items[0]
    }

    func configureForReadingSingle() {
        readTransaction.object = item.archive
    }

    func configureForReadingMultiple() {
        readTransaction.objects = items.archives
        readTransaction.keys = keys
    }

    // MARK: Tests

    // Writing

    func test__writer_initializes_with_single_item() {
        writer = Write(item)

        XCTAssertEqual(writer.items.first!.identifier, item.identifier)
    }

    func test__writer_initializes_with_multiple_items() {
        writer = Write(items)

        XCTAssertEqual(writer.items.map { $0.key }, keys)
    }

    func test__write_on_transaction() {
        writer = Write(item)
        writer.on(writeTransaction)

        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(Inventory.unarchive(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].2 as? NSNumber, item.metadata)
    }

    func test__write_sync() {
        writer = Write(item)
        writer.sync(connection)

        XCTAssertTrue(connection.didWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(Inventory.unarchive(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].2 as? NSNumber, item.metadata)
    }

    func test__write_async() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        writer = Write(item)
        writer.async(connection, queue: dispatchQueue) {
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertTrue(connection.didAsyncWrite)
        XCTAssertFalse(connection.didWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(Inventory.unarchive(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].2 as? NSNumber, item.metadata)
    }

    func test__write_operation() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        writer = Write(item)
        let operation = writer.operation(connection)
        operation.completionBlock = {
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)

        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertTrue(connection.didWriteBlockOperation)
        XCTAssertFalse(connection.didWrite)
        XCTAssertFalse(connection.didAsyncWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(Inventory.unarchive(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].2 as? NSNumber, item.metadata)
    }

    // Reading - Internal

    func test__reader__in_transaction_at_index() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        guard let item = reader.inTransaction(readTransaction, atIndex: index) else {
            XCTFail("Expecting to have an item"); return
        }
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(item.identifier, item.identifier)
    }

    func test__reader__in_transaction_at_index_2() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let atIndex = reader.inTransactionAtIndex(readTransaction)
        guard let item = atIndex(index) else {
            XCTFail("Expecting to have an item"); return
        }
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(item.identifier, item.identifier)
    }

    func test__reader__at_index_in_transaction() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let inTransaction = reader.atIndexInTransaction(index)
        guard let item = inTransaction(readTransaction) else {
            XCTFail("Expecting to have an item"); return
        }
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(item.identifier, item.identifier)
    }

    func test__reader__at_indexes_in_transaction_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let items = reader.atIndexesInTransaction(indexes)(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader__at_indexes_in_transaction_with_no_items() {
        reader = Read(readTransaction)
        let items = reader.atIndexesInTransaction(indexes)(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items, [])
    }

    func test__reader__in_transaction_by_key() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        guard let item = reader.inTransaction(readTransaction, byKey: key) else {
            XCTFail("Expecting to have an item"); return
        }
        XCTAssertEqual(readTransaction.didReadAtIndex, index)
        XCTAssertEqual(item.identifier, item.identifier)
    }

    func test__reader__in_transaction_by_key_2() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let byKey = reader.inTransactionByKey(readTransaction)
        guard let item = byKey(key) else {
            XCTFail("Expecting to have an item"); return
        }
        XCTAssertEqual(readTransaction.didReadAtIndex, index)
        XCTAssertEqual(item.identifier, item.identifier)
    }

    func test__reader__by_key_in_transaction() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let inTransaction = reader.byKeyInTransaction(key)
        guard let item = inTransaction(readTransaction) else {
            XCTFail("Expecting to have an item"); return
        }
        XCTAssertEqual(readTransaction.didReadAtIndex, index)
        XCTAssertEqual(item.identifier, item.identifier)
    }

    func test__reader__by_keys_in_transaction_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let items = reader.byKeysInTransaction(keys)(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader__by_keys_in_transaction_with_items_with_no_keys() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let items = reader.byKeysInTransaction()(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(readTransaction.didKeysInCollection!, Inventory.collection)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader__by_keys_in_transaction_with_no_items() {
        reader = Read(readTransaction)
        let items = reader.byKeysInTransaction(keys)(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items, [])
    }

    // Reading - With Transaction

    func test__reader_with_transaction__at_index_with_item() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        guard let item = reader.atIndex(index) else {
            XCTFail("Expecting to have an item"); return
        }
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(item.identifier, item.identifier)
    }

    func test__reader_with_transaction__at_index_with_no_item() {
        reader = Read(readTransaction)
        let item = reader.atIndex(index)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertNil(item)
    }

    func test__reader_with_transaction__at_indexes_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let items = reader.atIndexes(indexes)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_transaction__at_indexes_with_no_items() {
        reader = Read(readTransaction)
        let items = reader.atIndexes(indexes)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items, [])
    }

    func test__reader_with_transaction__by_key_with_item() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        guard let item = reader.byKey(key) else {
            XCTFail("Expecting to have an item"); return
        }
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(item.identifier, item.identifier)
    }

    func test__reader_with_transaction__by_key_with_no_item() {
        reader = Read(readTransaction)
        let item = reader.byKey(key)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertNil(item)
    }

    func test__reader_with_transaction__by_keys_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let items = reader.byKeys(keys)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_transaction__by_keys_with_no_items() {
        reader = Read(readTransaction)
        let items = reader.byKeys(keys)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items, [])
    }

    func test__reader_with_transaction__all_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let items = reader.all()
        XCTAssertEqual(readTransaction.didKeysInCollection, Inventory.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_transaction__all_with_no_items() {
        reader = Read(readTransaction)
        let items = reader.all()
        XCTAssertEqual(readTransaction.didKeysInCollection, Inventory.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, [])
        XCTAssertEqual(items, [])
    }

    func test__reader_with_transaction__filter() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let (items, missing) = reader.filterExisting(keys)
        XCTAssertEqual(readTransaction.didReadAtIndexes.first!, indexes.first!)
        XCTAssertEqual(items.map { $0.identifier }, items.prefixUpTo(1).map { $0.identifier })
        XCTAssertEqual(missing, Array(keys.suffixFrom(1)))
    }

    // Reading - With Connection

    func test__reader_with_connection__at_index_with_item() {
        configureForReadingSingle()
        reader = Read(connection)
        guard let item = reader.atIndex(index) else {
            XCTFail("Expecting to have an item"); return
        }
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(item.identifier, item.identifier)
    }

    func test__reader_with_connection__at_index_with_no_item() {
        reader = Read(connection)
        let item = reader.atIndex(index)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertNil(item)
    }

    func test__reader_with_connection__at_indexes_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        let items = reader.atIndexes(indexes)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_connection__at_indexes_with_no_items() {
        reader = Read(connection)
        let items = reader.atIndexes(indexes)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items, [])
    }

    func test__reader_with_connection__by_key_with_item() {
        configureForReadingSingle()
        reader = Read(connection)
        guard let item = reader.byKey(key) else {
            XCTFail("Expecting to have an item"); return
        }
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(item.identifier, item.identifier)
    }

    func test__reader_with_connection__by_key_with_no_item() {
        reader = Read(connection)
        let item = reader.byKey(key)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertNil(item)
    }

    func test__reader_with_connection__by_keys_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        let items = reader.byKeys(keys)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_connection__by_keys_with_no_items() {
        reader = Read(connection)
        let items = reader.byKeys(keys)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items, [])
    }

    func test__reader_with_connection__all_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        let items = reader.all()
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didKeysInCollection, Inventory.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_connection__all_with_no_items() {
        reader = Read(connection)
        let items = reader.all()
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didKeysInCollection, Inventory.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, [])
        XCTAssertEqual(items, [])
    }

    func test__reader_with_connection__filter() {
        configureForReadingSingle()
        reader = Read(connection)
        let (items, missing) = reader.filterExisting(keys)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndexes.first!, indexes.first!)
        XCTAssertEqual(items.map { $0.identifier }, items.prefixUpTo(1).map { $0.identifier })
        XCTAssertEqual(missing, Array(keys.suffixFrom(1)))
    }


    // Functional API - ReadTransactionType - Reading

    func test__transaction__read_at_index_with_data() {
        configureForReadingSingle()
        let inventory: Inventory? = readTransaction.readAtIndex(index)
        XCTAssertNotNil(inventory)
        XCTAssertEqual(inventory!.identifier, item.identifier)
    }

    func test__transaction__read_at_index_without_data() {
        let inventory: Inventory? = readTransaction.readAtIndex(index)
        XCTAssertNil(inventory)
    }

    func test__transaction__read_at_indexes_with_data() {
        configureForReadingMultiple()
        let inventorys: [Inventory] = readTransaction.readAtIndexes(indexes)
        XCTAssertEqual(inventorys.count, items.count)
    }

    func test__transaction__read_at_indexes_without_data() {
        let inventorys: [Inventory] = readTransaction.readAtIndexes(indexes)
        XCTAssertNotNil(inventorys)
        XCTAssertTrue(inventorys.isEmpty)
    }

    func test__transaction__read_by_key_with_data() {
        configureForReadingSingle()
        let inventory: Inventory? = readTransaction.readByKey(key)
        XCTAssertNotNil(inventory)
        XCTAssertEqual(inventory!.identifier, item.identifier)
    }

    func test__transaction__read_by_key_without_data() {
        let inventory: Inventory? = readTransaction.readByKey(key)
        XCTAssertNil(inventory)
    }

    func test__transaction__read_by_keys_with_data() {
        configureForReadingMultiple()
        let inventorys: [Inventory] = readTransaction.readByKeys(keys)
        XCTAssertEqual(inventorys.count, items.count)
    }

    func test__transaction__read_by_keys_without_data() {
        let inventorys: [Inventory] = readTransaction.readByKeys(keys)
        XCTAssertNotNil(inventorys)
        XCTAssertTrue(inventorys.isEmpty)
    }

    // Functional API - ConnectionType - Reading

    func test__connection__read_at_index_with_data() {
        configureForReadingSingle()
        let inventory: Inventory? = connection.readAtIndex(index)
        XCTAssertNotNil(inventory)
        XCTAssertEqual(inventory!.identifier, item.identifier)
    }

    func test__connection__read_at_index_without_data() {
        let inventory: Inventory? = connection.readAtIndex(index)
        XCTAssertNil(inventory)
    }

    func test__connection__read_at_indexes_with_data() {
        configureForReadingMultiple()
        let inventorys: [Inventory] = connection.readAtIndexes(indexes)
        XCTAssertEqual(inventorys.count, items.count)
    }

    func test__connection__read_at_indexes_without_data() {
        let inventorys: [Inventory] = connection.readAtIndexes(indexes)
        XCTAssertNotNil(inventorys)
        XCTAssertTrue(inventorys.isEmpty)
    }

    func test__connection__read_by_key_with_data() {
        configureForReadingSingle()
        let inventory: Inventory? = connection.readByKey(key)
        XCTAssertNotNil(inventory)
        XCTAssertEqual(inventory!.identifier, item.identifier)
    }

    func test__connection__read_by_key_without_data() {
        let inventory: Inventory? = connection.readByKey(key)
        XCTAssertNil(inventory)
    }

    func test__connection__read_by_keys_with_data() {
        configureForReadingMultiple()
        let inventorys: [Inventory] = connection.readByKeys(keys)
        XCTAssertEqual(inventorys.count, items.count)
    }

    func test__connection__read_by_keys_without_data() {
        let inventorys: [Inventory] = connection.readByKeys(keys)
        XCTAssertNotNil(inventorys)
        XCTAssertTrue(inventorys.isEmpty)
    }


}

