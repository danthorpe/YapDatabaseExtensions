//
//  ValueWithNoMetadataTests.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 09/10/2015.
//  Copyright © 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import XCTest
import ValueCoding
@testable import YapDatabaseExtensions

class ValueWithNoMetadataTests: XCTestCase {

    var item: Barcode!
    var index: YapDB.Index!
    var key: String!

    var items: [Barcode]!
    var indexes: [YapDB.Index]!
    var keys: [String]!

    var database: TestableDatabase!
    var connection: TestableConnection!
    var writeTransaction: TestableWriteTransaction!
    var readTransaction: TestableReadTransaction!

    var reader: Read<Barcode, TestableDatabase>!
    var writer: Write<Barcode, TestableDatabase>!

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
        item = .QRCode("I have no idea what the string of a QR Code might look like")
        items = [
            item,
            .UPCA(23, 42, 78, 93),
            .QRCode("This is a different QR Code!"),
            .UPCA(68, 59, 147, 291)
        ]
    }

    func configureForReadingSingle() {
        readTransaction.object = item.encoded
    }

    func configureForReadingMultiple() {
        readTransaction.objects = items.encoded
        readTransaction.keys = keys
    }

    // MARK: Tests

    func test__metadata_is_nil() {
        XCTAssertNil(item.metadata)
    }

    func test__metadata_cannot_be_set() {
        item.metadata = Void()
        XCTAssertNil(item.metadata)
    }

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
        XCTAssertEqual(Barcode.decode(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
    }

    func test__write_sync() {
        writer = Write(item)
        writer.sync(connection)

        XCTAssertTrue(connection.didWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(Barcode.decode(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
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
        XCTAssertEqual(Barcode.decode(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
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
        XCTAssertEqual(Barcode.decode(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
    }

    // Reading - Internal

    func test__reader__in_transaction_at_index() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let result = reader.inTransaction(readTransaction, atIndex: index)
        XCTAssertNotNil(result)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
    }

    func test__reader__in_transaction_at_index_2() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let atIndex = reader.inTransactionAtIndex(readTransaction)
        let result = atIndex(index)
        XCTAssertNotNil(result)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
    }

    func test__reader__at_index_in_transaction() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let inTransaction = reader.atIndexInTransaction(index)
        let result = inTransaction(readTransaction)
        XCTAssertNotNil(result)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
    }

    func test__reader__at_indexes_in_transaction_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let result = reader.atIndexesInTransaction(indexes)(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader__at_indexes_in_transaction_with_no_items() {
        reader = Read(readTransaction)
        let result = reader.atIndexesInTransaction(indexes)(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result, [])
    }

    func test__reader__in_transaction_by_key() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let result = reader.inTransaction(readTransaction, byKey: key)
        XCTAssertNotNil(result)
        XCTAssertEqual(readTransaction.didReadAtIndex, index)
        XCTAssertEqual(result!.identifier, item.identifier)
    }

    func test__reader__in_transaction_by_key_2() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let byKey = reader.inTransactionByKey(readTransaction)
        let result = byKey(key)
        XCTAssertNotNil(result)
        XCTAssertEqual(readTransaction.didReadAtIndex, index)
        XCTAssertEqual(result!.identifier, item.identifier)
    }

    func test__reader__by_key_in_transaction() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let inTransaction = reader.byKeyInTransaction(key)
        let result = inTransaction(readTransaction)
        XCTAssertNotNil(result)
        XCTAssertEqual(readTransaction.didReadAtIndex, index)
        XCTAssertEqual(result!.identifier, item.identifier)
    }

    func test__reader__by_keys_in_transaction_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let result = reader.byKeysInTransaction(keys)(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader__by_keys_in_transaction_with_items_with_no_keys() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let result = reader.byKeysInTransaction()(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(readTransaction.didKeysInCollection!, Barcode.collection)
        XCTAssertEqual(result.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader__by_keys_in_transaction_with_no_items() {
        reader = Read(readTransaction)
        let result = reader.byKeysInTransaction(keys)(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result, [])
    }

    // Reading - With Transaction

    func test__reader_with_transaction__at_index_with_item() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let result = reader.atIndex(index)
        XCTAssertNotNil(result)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
    }

    func test__reader_with_transaction__at_index_with_no_item() {
        reader = Read(readTransaction)
        let result = reader.atIndex(index)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertNil(result)
    }

    func test__reader_with_transaction__at_indexes_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let result = reader.atIndexes(indexes)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_transaction__at_indexes_with_no_items() {
        reader = Read(readTransaction)
        let result = reader.atIndexes(indexes)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result, [])
    }

    func test__reader_with_transaction__by_key_with_item() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let result = reader.byKey(key)
        XCTAssertNotNil(result)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
    }

    func test__reader_with_transaction__by_key_with_no_item() {
        reader = Read(readTransaction)
        let result = reader.byKey(key)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertNil(result)
    }

    func test__reader_with_transaction__by_keys_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let result = reader.byKeys(keys)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_transaction__by_keys_with_no_items() {
        reader = Read(readTransaction)
        let result = reader.byKeys(keys)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result, [])
    }

    func test__reader_with_transaction__all_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let result = reader.all()
        XCTAssertEqual(readTransaction.didKeysInCollection, Barcode.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_transaction__all_with_no_items() {
        reader = Read(readTransaction)
        let result = reader.all()
        XCTAssertEqual(readTransaction.didKeysInCollection, Barcode.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, [])
        XCTAssertEqual(result, [])
    }

    func test__reader_with_transaction__filter() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let (result, missing) = reader.filterExisting(keys)
        XCTAssertEqual(readTransaction.didReadAtIndexes.first!, indexes.first!)
        XCTAssertEqual(result.map { $0.identifier }, items.prefixUpTo(1).map { $0.identifier })
        XCTAssertEqual(missing, Array(keys.suffixFrom(1)))
    }

    // Reading - With Connection

    func test__reader_with_connection__at_index_with_item() {
        configureForReadingSingle()
        reader = Read(connection)
        let result = reader.atIndex(index)
        XCTAssertNotNil(result)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
    }

    func test__reader_with_connection__at_index_with_no_item() {
        reader = Read(connection)
        let result = reader.atIndex(index)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertNil(result)
    }

    func test__reader_with_connection__at_indexes_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        let result = reader.atIndexes(indexes)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_connection__at_indexes_with_no_items() {
        reader = Read(connection)
        let result = reader.atIndexes(indexes)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result, [])
    }

    func test__reader_with_connection__by_key_with_item() {
        configureForReadingSingle()
        reader = Read(connection)
        let result = reader.byKey(key)
        XCTAssertNotNil(result)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
    }

    func test__reader_with_connection__by_key_with_no_item() {
        reader = Read(connection)
        let result = reader.byKey(key)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertNil(result)
    }

    func test__reader_with_connection__by_keys_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        let result = reader.byKeys(keys)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_connection__by_keys_with_no_items() {
        reader = Read(connection)
        let result = reader.byKeys(keys)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result, [])
    }

    func test__reader_with_connection__all_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        let result = reader.all()
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didKeysInCollection, Barcode.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(result.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_connection__all_with_no_items() {
        reader = Read(connection)
        let result = reader.all()
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didKeysInCollection, Barcode.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, [])
        XCTAssertEqual(result, [])
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
        let barcode: Barcode? = readTransaction.readAtIndex(index)
        XCTAssertNotNil(barcode)
        XCTAssertEqual(barcode!.identifier, item.identifier)
        XCTAssertNil(barcode!.metadata)
    }

    func test__transaction__read_at_index_without_data() {
        let barcode: Barcode? = readTransaction.readAtIndex(index)
        XCTAssertNil(barcode)
    }

    func test__transaction__read_at_indexes_with_data() {
        configureForReadingMultiple()
        let barcodes: [Barcode] = readTransaction.readAtIndexes(indexes)
        XCTAssertEqual(barcodes.count, items.count)
    }

    func test__transaction__read_at_indexes_without_data() {
        let barcodes: [Barcode] = readTransaction.readAtIndexes(indexes)
        XCTAssertNotNil(barcodes)
        XCTAssertTrue(barcodes.isEmpty)
    }

    func test__transaction__read_by_key_with_data() {
        configureForReadingSingle()
        let barcode: Barcode? = readTransaction.readByKey(key)
        XCTAssertNotNil(barcode)
        XCTAssertEqual(barcode!.identifier, item.identifier)
        XCTAssertNil(barcode!.metadata)
    }

    func test__transaction__read_by_key_without_data() {
        let barcode: Barcode? = readTransaction.readByKey(key)
        XCTAssertNil(barcode)
    }

    func test__transaction__read_by_keys_with_data() {
        configureForReadingMultiple()
        let barcodes: [Barcode] = readTransaction.readByKeys(keys)
        XCTAssertEqual(barcodes.count, items.count)
    }

    func test__transaction__read_by_keys_without_data() {
        let barcodes: [Barcode] = readTransaction.readByKeys(keys)
        XCTAssertNotNil(barcodes)
        XCTAssertTrue(barcodes.isEmpty)
    }

    // Functional API - ConnectionType - Reading

    func test__connection__read_at_index_with_data() {
        configureForReadingSingle()
        let barcode: Barcode? = connection.readAtIndex(index)
        XCTAssertNotNil(barcode)
        XCTAssertEqual(barcode!.identifier, item.identifier)
        XCTAssertNil(barcode!.metadata)
    }

    func test__connection__read_at_index_without_data() {
        let barcode: Barcode? = connection.readAtIndex(index)
        XCTAssertNil(barcode)
    }

    func test__connection__read_at_indexes_with_data() {
        configureForReadingMultiple()
        let barcodes: [Barcode] = connection.readAtIndexes(indexes)
        XCTAssertEqual(barcodes.count, items.count)
    }

    func test__connection__read_at_indexes_without_data() {
        let barcodes: [Barcode] = connection.readAtIndexes(indexes)
        XCTAssertNotNil(barcodes)
        XCTAssertTrue(barcodes.isEmpty)
    }

    func test__connection__read_by_key_with_data() {
        configureForReadingSingle()
        let barcode: Barcode? = connection.readByKey(key)
        XCTAssertNotNil(barcode)
        XCTAssertEqual(barcode!.identifier, item.identifier)
        XCTAssertNil(barcode!.metadata)
    }

    func test__connection__read_by_key_without_data() {
        let barcode: Barcode? = connection.readByKey(key)
        XCTAssertNil(barcode)
    }

    func test__connection__read_by_keys_with_data() {
        configureForReadingMultiple()
        let barcodes: [Barcode] = connection.readByKeys(keys)
        XCTAssertEqual(barcodes.count, items.count)
    }

    func test__connection__read_by_keys_without_data() {
        let barcodes: [Barcode] = connection.readByKeys(keys)
        XCTAssertNotNil(barcodes)
        XCTAssertTrue(barcodes.isEmpty)
    }

    // MARK: - Functional API - Transaction - Writing

    func test__transaction__write_item() {
        writeTransaction.write(item)

        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(Barcode.decode(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
    }

    func test__transaction__write_items() {
        writeTransaction.write(items)

        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sort(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
    }

    // Functional API - Connection - Writing

    func test__connection__write_item() {
        connection.write(item)

        XCTAssertTrue(connection.didWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(Barcode.decode(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
    }

    func test__connection__write_items() {
        connection.write(items)

        XCTAssertTrue(connection.didWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sort(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
    }

    func test__connection__async_write_item() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")
        connection.asyncWrite(item) { expectation.fulfill() }

        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertTrue(connection.didAsyncWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(Barcode.decode(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
    }

    func test__connection__async_write_items() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")
        connection.asyncWrite(items) { expectation.fulfill() }

        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertTrue(connection.didAsyncWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sort(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
    }



}

