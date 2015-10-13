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

    var item: Person!
    var index: YapDB.Index!
    var key: String!

    var items: [Person]!
    var indexes: [YapDB.Index]!
    var keys: [String]!

    var database: TestableDatabase!
    var connection: TestableConnection!
    var writeTransaction: TestableWriteTransaction!
    var readTransaction: TestableReadTransaction!

    var reader: Read<Person, TestableDatabase>!
    var writer: Write<Person, TestableDatabase>!

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
        item = Person(id: "beatle-1", name: "John")
        items = [
            Person(id: "beatle-1", name: "John"),
            Person(id: "beatle-2", name: "Paul"),
            Person(id: "beatle-3", name: "George"),
            Person(id: "beatle-4", name: "Ringo")
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
        XCTAssertEqual(readTransaction.didKeysInCollection!, Person.collection)
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
        XCTAssertEqual(readTransaction.didKeysInCollection, Person.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_transaction__all_with_no_items() {
        reader = Read(readTransaction)
        let items = reader.all()
        XCTAssertEqual(readTransaction.didKeysInCollection, Person.collection)
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
        XCTAssertEqual(readTransaction.didKeysInCollection, Person.collection)
        XCTAssertEqual(readTransaction.didReadAtIndexes, indexes)
        XCTAssertEqual(items.map { $0.identifier }, items.map { $0.identifier })
    }

    func test__reader_with_connection__all_with_no_items() {
        reader = Read(connection)
        let items = reader.all()
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didKeysInCollection, Person.collection)
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
        let person: Person? = readTransaction.readAtIndex(index)
        XCTAssertNotNil(person)
        XCTAssertEqual(person!.identifier, item.identifier)
        XCTAssertNil(person!.metadata)
    }

    func test__transaction__read_at_index_without_data() {
        let person: Person? = readTransaction.readAtIndex(index)
        XCTAssertNil(person)
    }

    func test__transaction__read_at_indexes_with_data() {
        configureForReadingMultiple()
        let people: [Person] = readTransaction.readAtIndexes(indexes)
        XCTAssertEqual(people.count, items.count)
    }

    func test__transaction__read_at_indexes_without_data() {
        let people: [Person] = readTransaction.readAtIndexes(indexes)
        XCTAssertNotNil(people)
        XCTAssertTrue(people.isEmpty)
    }

    func test__transaction__read_by_key_with_data() {
        configureForReadingSingle()
        let person: Person? = readTransaction.readByKey(key)
        XCTAssertNotNil(person)
        XCTAssertEqual(person!.identifier, item.identifier)
        XCTAssertNil(person!.metadata)
    }

    func test__transaction__read_by_key_without_data() {
        let person: Person? = readTransaction.readByKey(key)
        XCTAssertNil(person)
    }

    func test__transaction__read_by_keys_with_data() {
        configureForReadingMultiple()
        let people: [Person] = readTransaction.readByKeys(keys)
        XCTAssertEqual(people.count, items.count)
    }

    func test__transaction__read_by_keys_without_data() {
        let people: [Person] = readTransaction.readByKeys(keys)
        XCTAssertNotNil(people)
        XCTAssertTrue(people.isEmpty)
    }

    // Functional API - ConnectionType - Reading

    func test__connection__read_at_index_with_data() {
        configureForReadingSingle()
        let person: Person? = connection.readAtIndex(index)
        XCTAssertNotNil(person)
        XCTAssertEqual(person!.identifier, item.identifier)
        XCTAssertNil(person!.metadata)
    }

    func test__connection__read_at_index_without_data() {
        let person: Person? = connection.readAtIndex(index)
        XCTAssertNil(person)
    }

    func test__connection__read_at_indexes_with_data() {
        configureForReadingMultiple()
        let people: [Person] = connection.readAtIndexes(indexes)
        XCTAssertEqual(people.count, items.count)
    }

    func test__connection__read_at_indexes_without_data() {
        let people: [Person] = connection.readAtIndexes(indexes)
        XCTAssertNotNil(people)
        XCTAssertTrue(people.isEmpty)
    }

    func test__connection__read_by_key_with_data() {
        configureForReadingSingle()
        let person: Person? = connection.readByKey(key)
        XCTAssertNotNil(person)
        XCTAssertEqual(person!.identifier, item.identifier)
        XCTAssertNil(person!.metadata)
    }

    func test__connection__read_by_key_without_data() {
        let person: Person? = connection.readByKey(key)
        XCTAssertNil(person)
    }

    func test__connection__read_by_keys_with_data() {
        configureForReadingMultiple()
        let people: [Person] = connection.readByKeys(keys)
        XCTAssertEqual(people.count, items.count)
    }

    func test__connection__read_by_keys_without_data() {
        let people: [Person] = connection.readByKeys(keys)
        XCTAssertNotNil(people)
        XCTAssertTrue(people.isEmpty)
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

    func test__connection__async_write_item() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")
        connection.asyncWrite(item) { expectation.fulfill() }

        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertTrue(connection.didAsyncWrite)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
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

