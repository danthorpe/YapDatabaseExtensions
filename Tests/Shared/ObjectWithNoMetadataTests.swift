//
//  ObjectWithNoMetadataTests.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 09/10/2015.
//  Copyright © 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import XCTest
@testable import YapDatabaseExtensions

class ObjectWithNoMetadataTests: XCTestCase {

    typealias TypeUnderTest = Person

    var item: TypeUnderTest!
    var index: YapDB.Index!
    var key: String!

    var items: [TypeUnderTest]!
    var indexes: [YapDB.Index]!
    var keys: [String]!

    var database: TestableDatabase!
    var connection: TestableConnection!
    var writeTransaction: TestableWriteTransaction!
    var readTransaction: TestableReadTransaction!

    var reader: Read<TypeUnderTest, TestableDatabase>!
    var writer: Write<TypeUnderTest, TestableDatabase>!

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
        item = TypeUnderTest(id: "beatle-1", name: "John")
        items = [
            TypeUnderTest(id: "beatle-1", name: "John"),
            TypeUnderTest(id: "beatle-2", name: "Paul"),
            TypeUnderTest(id: "beatle-3", name: "George"),
            TypeUnderTest(id: "beatle-4", name: "Ringo")
        ]
    }

    func configureForReadingSingle() {
        readTransaction.object = item
    }

    func configureForReadingMultiple() {
        readTransaction.objects = items
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
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
    }

    func test__write_sync() {
        writer = Write(item)
        writer.sync(connection)

        XCTAssertTrue(connection.didWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
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
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
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
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
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
        let result = reader.inTransaction(readTransaction, atIndex: index)
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
        let items = reader.byKeysInTransaction(keys)(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader__by_keys_in_transaction_with_items_with_no_keys() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        let items = reader.byKeysInTransaction()(readTransaction)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(readTransaction.didKeysInCollection!, TypeUnderTest.collection)
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
        let result = reader.inTransaction(readTransaction, atIndex: index)
        XCTAssertNotNil(result)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
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
        let result = reader.inTransaction(readTransaction, atIndex: index)
        XCTAssertNotNil(result)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
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
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_transaction__all_with_no_items() {
        reader = Read(readTransaction)
        let items = reader.all()
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
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
        let result = reader.atIndex(index)
        XCTAssertNotNil(result)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
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
        let result = reader.byKey(key)
        XCTAssertNotNil(result)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndex!, index)
        XCTAssertEqual(result!.identifier, item.identifier)
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
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_connection__all_with_no_items() {
        reader = Read(connection)
        let items = reader.all()
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
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

    // Persistable Curried API - Reading

    func test__curried__read_at_index_with_data() {
        configureForReadingSingle()
        let result = connection.read(TypeUnderTest.readAtIndex(index))
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.identifier, item.identifier)
        XCTAssertNil(result!.metadata)
    }

    func test__curried__read_at_index_with_no_data() {
        let result = connection.read(TypeUnderTest.readAtIndex(index))
        XCTAssertNil(result)
    }

    func test__curried__read_at_indexes_with_data() {
        configureForReadingMultiple()
        let result = connection.read(TypeUnderTest.readAtIndexes(indexes))
        XCTAssertEqual(result.count, items.count)
    }

    func test__curried__read_at_indexes_with_no_data() {
        let result = connection.read(TypeUnderTest.readAtIndexes(indexes))
        XCTAssertNotNil(result)
        XCTAssertTrue(result.isEmpty)
    }

    func test__curried__read_by_key_with_data() {
        configureForReadingSingle()
        let result = connection.read(TypeUnderTest.readByKey(key))
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.identifier, item.identifier)
        XCTAssertNil(result!.metadata)
    }

    func test__curried__read_by_key_with_no_data() {
        let result = connection.read(TypeUnderTest.readByKey(key))
        XCTAssertNil(result)
    }

    func test__curried__read_by_keys_with_data() {
        configureForReadingMultiple()
        let result = connection.read(TypeUnderTest.readByKeys(keys))
        XCTAssertEqual(result.count, items.count)
    }

    func test__curried__read_by_keys_with_no_data() {
        let result = connection.read(TypeUnderTest.readByKeys(keys))
        XCTAssertNotNil(result)
        XCTAssertTrue(result.isEmpty)
    }

    // Persistable Curried API - Writing

    func test__curried__writeOn() {
        let result = connection.write(item.writeOn())

        XCTAssertTrue(connection.didWrite)        
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
        XCTAssertEqual(result, item)
    }

    // Functional API - ReadTransactionType - Reading

    func test__transaction__read_at_index_with_data() {
        configureForReadingSingle()
        let result: TypeUnderTest? = readTransaction.readAtIndex(index)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.identifier, item.identifier)
        XCTAssertNil(result!.metadata)
    }

    func test__transaction__read_at_index_without_data() {
        let result: TypeUnderTest? = readTransaction.readAtIndex(index)
        XCTAssertNil(result)
    }

    func test__transaction__read_at_indexes_with_data() {
        configureForReadingMultiple()
        let result: [TypeUnderTest] = readTransaction.readAtIndexes(indexes)
        XCTAssertEqual(result.count, items.count)
    }

    func test__transaction__read_at_indexes_with_data_2() {
        configureForReadingMultiple()
        let result: [TypeUnderTest] = readTransaction.readAtIndexes(Set(indexes))
        XCTAssertEqual(result.count, items.count)
    }

    func test__transaction__read_at_indexes_without_data() {
        let result: [TypeUnderTest] = readTransaction.readAtIndexes(indexes)
        XCTAssertNotNil(result)
        XCTAssertTrue(result.isEmpty)
    }

    func test__transaction__read_by_key_with_data() {
        configureForReadingSingle()
        let result: TypeUnderTest? = readTransaction.readByKey(key)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.identifier, item.identifier)
        XCTAssertNil(result!.metadata)
    }

    func test__transaction__read_by_key_without_data() {
        let result: TypeUnderTest? = readTransaction.readByKey(key)
        XCTAssertNil(result)
    }

    func test__transaction__read_by_keys_with_data() {
        configureForReadingMultiple()
        let result: [TypeUnderTest] = readTransaction.readByKeys(keys)
        XCTAssertEqual(result.count, items.count)
    }

    func test__transaction__read_by_keys_with_data_2() {
        configureForReadingMultiple()
        let result: [TypeUnderTest] = readTransaction.readByKeys(Set(keys))
        XCTAssertEqual(result.count, items.count)
    }

    func test__transaction__read_by_keys_without_data() {
        let result: [TypeUnderTest] = readTransaction.readByKeys(keys)
        XCTAssertNotNil(result)
        XCTAssertTrue(result.isEmpty)
    }

    func test__transaction__read_all_with_data() {
        configureForReadingMultiple()
        let result: [TypeUnderTest] = readTransaction.readAll()
        XCTAssertEqual(Set(readTransaction.didReadAtIndexes), Set(indexes))
        XCTAssertEqual(result.count, items.count)
    }

    // Functional API - ConnectionType - Reading

    func test__connection__read_at_index_with_data() {
        configureForReadingSingle()
        let result: TypeUnderTest? = connection.readAtIndex(index)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.identifier, item.identifier)
        XCTAssertNil(result!.metadata)
    }

    func test__connection__read_at_index_without_data() {
        let result: TypeUnderTest? = connection.readAtIndex(index)
        XCTAssertNil(result)
    }

    func test__connection__read_at_indexes_with_data() {
        configureForReadingMultiple()
        let result: [TypeUnderTest] = connection.readAtIndexes(indexes)
        XCTAssertEqual(result.count, items.count)
    }

    func test__connection__read_at_indexes_with_data_2() {
        configureForReadingMultiple()
        let result: [TypeUnderTest] = connection.readAtIndexes(Set(indexes))
        XCTAssertEqual(result.count, items.count)
    }

    func test__connection__read_at_indexes_without_data() {
        let result: [TypeUnderTest] = connection.readAtIndexes(indexes)
        XCTAssertNotNil(result)
        XCTAssertTrue(result.isEmpty)
    }

    func test__connection__read_by_key_with_data() {
        configureForReadingSingle()
        let result: TypeUnderTest? = connection.readByKey(key)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.identifier, item.identifier)
        XCTAssertNil(result!.metadata)
    }

    func test__connection__read_by_key_without_data() {
        let result: TypeUnderTest? = connection.readByKey(key)
        XCTAssertNil(result)
    }

    func test__connection__read_by_keys_with_data() {
        configureForReadingMultiple()
        let result: [TypeUnderTest] = connection.readByKeys(keys)
        XCTAssertEqual(result.count, items.count)
    }

    func test__connection__read_by_keys_with_data_2() {
        configureForReadingMultiple()
        let result: [TypeUnderTest] = connection.readByKeys(Set(keys))
        XCTAssertEqual(result.count, items.count)
    }

    func test__connection__read_by_keys_without_data() {
        let result: [TypeUnderTest] = connection.readByKeys(keys)
        XCTAssertNotNil(result)
        XCTAssertTrue(result.isEmpty)
    }

    func test__connection__read_all_with_data() {
        configureForReadingMultiple()
        let result: [TypeUnderTest] = connection.readAll()
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(Set(readTransaction.didReadAtIndexes), Set(indexes))
        XCTAssertEqual(result.count, items.count)
    }

    // MARK: - Functional API - Transaction - Writing

    func test__transaction__write_item() {
        writeTransaction.write(item)

        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
    }

    func test__transaction__write_items() {
        writeTransaction.write(items)

        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sort(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
    }

    func test__transaction__write_items_2() {
        writeTransaction.write(Set(items))

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
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
    }

    func test__connection__write_items() {
        connection.write(items)

        XCTAssertTrue(connection.didWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sort(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
    }

    func test__connection__write_items_2() {
        connection.write(Set(items))

        XCTAssertTrue(connection.didWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sort(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
    }

    func test__connection__async_write_item() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")
        connection.asyncWrite(item) { _ in expectation.fulfill() }

        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertTrue(connection.didAsyncWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
    }

    func test__connection__async_write_items() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")
        var result: [TypeUnderTest] = []
        connection.asyncWrite(items) { received in
            result = received
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertTrue(connection.didAsyncWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sort(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(result, items)
    }
}

