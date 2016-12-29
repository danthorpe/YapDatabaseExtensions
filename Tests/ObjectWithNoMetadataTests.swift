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

    var dispatchQueue: DispatchQueue!
    var operationQueue: OperationQueue!

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

        dispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.`default`)
        operationQueue = OperationQueue()
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

    func checkTransactionDidWriteItem(_ result: TypeUnderTest) {
        XCTAssertEqual(result.identifier, item.identifier)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
    }

    func checkTransactionDidWriteItems(_ result: [TypeUnderTest]) {
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sorted(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(Set(result), Set(items))
    }

    func checkTransactionDidReadItem(_ result: TypeUnderTest?) -> Bool {
        guard let result = result else {
            return false
        }
        XCTAssertEqual(readTransaction.didReadAtIndex, index)
        XCTAssertEqual(result.identifier, item.identifier)
        return true
    }

    func checkTransactionDidReadItems(_ result: [TypeUnderTest]) -> Bool {
        if result.isEmpty {
            return false
        }
        XCTAssertEqual(Set(readTransaction.didReadAtIndexes), Set(indexes))
        XCTAssertEqual(result.count, items.count)
        return true
    }

    func checkTransactionDidRemoveItem() {
        XCTAssertEqual(writeTransaction.didRemoveAtIndexes.count, 1)
        XCTAssertEqual(writeTransaction.didRemoveAtIndexes.first!, index)
    }

    func checkTransactionDidRemoveItems() {
        XCTAssertEqual(writeTransaction.didRemoveAtIndexes, indexes)
    }
}

class Functional_Read_ObjectWithNoMetadataTests: ObjectWithNoMetadataTests {

    // Functional API - ReadTransactionType - Reading

    func test__transaction__read_at_index_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(readTransaction.readAtIndex(index)))
    }

    func test__transaction__read_at_index_without_data() {
        XCTAssertFalse(checkTransactionDidReadItem(readTransaction.readAtIndex(index)))
    }

    func test__transaction__read_at_indexes_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(readTransaction.readAtIndexes(indexes)))
    }

    func test__transaction__read_at_indexes_with_data_2() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(readTransaction.readAtIndexes(Set(indexes))))
    }

    func test__transaction__read_at_indexes_without_data() {
        XCTAssertFalse(checkTransactionDidReadItems(readTransaction.readAtIndexes(indexes)))
    }

    func test__transaction__read_by_key_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(readTransaction.readByKey(key)))
    }

    func test__transaction__read_by_key_without_data() {
        XCTAssertFalse(checkTransactionDidReadItem(readTransaction.readByKey(key)))
    }

    func test__transaction__read_by_keys_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(readTransaction.readByKeys(keys)))
    }

    func test__transaction__read_by_keys_with_data_2() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(readTransaction.readByKeys(Set(keys))))
    }

    func test__transaction__read_by_keys_without_data() {
        XCTAssertFalse(checkTransactionDidReadItems(readTransaction.readByKeys(keys)))
    }

    func test__transaction__read_all_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(readTransaction.readAll()))
    }

    // Functional API - ConnectionType - Reading

    func test__connection__read_at_index_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(connection.readAtIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_at_index_without_data() {
        XCTAssertFalse(checkTransactionDidReadItem(connection.readAtIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_at_indexes_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.readAtIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_at_indexes_with_data_2() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.readAtIndexes(Set(indexes))))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_at_indexes_without_data() {
        XCTAssertFalse(checkTransactionDidReadItems(connection.readAtIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_by_key_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(connection.readByKey(key)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_by_key_without_data() {
        XCTAssertFalse(checkTransactionDidReadItem(connection.readByKey(key)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_by_keys_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.readByKeys(keys)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_by_keys_with_data_2() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.readByKeys(Set(keys))))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_by_keys_without_data() {
        XCTAssertFalse(checkTransactionDidReadItems(connection.readByKeys(keys)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_all_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.readAll()))
        XCTAssertTrue(connection.didRead)
    }
}

class Functional_Write_ObjectWithNoMetadataTests: ObjectWithNoMetadataTests {

    func test__transaction__write_item() {
        checkTransactionDidWriteItem(writeTransaction.write(item))
    }

    func test__transaction__write_items() {
        checkTransactionDidWriteItems(writeTransaction.write(items))
    }

    func test__transaction__write_items_2() {
        checkTransactionDidWriteItems(writeTransaction.write(Set(items)))
    }

    // MARK: - Functional API - Connection - Writing

    func test__connection__write_item() {
        checkTransactionDidWriteItem(connection.write(item))
        XCTAssertTrue(connection.didWrite)
    }

    func test__connection__write_items() {
        checkTransactionDidWriteItems(connection.write(items))
        XCTAssertTrue(connection.didWrite)
    }

    func test__connection__write_items_2() {
        checkTransactionDidWriteItems(connection.write(Set(items)))
        XCTAssertTrue(connection.didWrite)
    }

    func test__connection__async_write_item() {
        var result: TypeUnderTest!
        let expectation = self.expectation(description: "Test: \(#function)")
        connection.asyncWrite(item) { tmp in
            result = tmp
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidWriteItem(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__connection__async_write_items() {
        var result: [TypeUnderTest] = []
        let expectation = self.expectation(description: "Test: \(#function)")
        connection.asyncWrite(items) { received in
            result = received
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidWriteItems(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }
}

class Functional_Remove_ObjectWithNoMetadataTests: ObjectWithNoMetadataTests {

    func test__transaction_remove_item() {
        configureForReadingSingle()
        writeTransaction.remove(item)
        checkTransactionDidRemoveItem()
    }

    func test__transaction_remove_items() {
        configureForReadingMultiple()
        writeTransaction.remove(items)
        checkTransactionDidRemoveItems()
    }

    func test__connection_remove_item() {
        configureForReadingSingle()
        connection.remove(item)
        checkTransactionDidRemoveItem()
        XCTAssertTrue(connection.didWrite)
    }

    func test__connection_remove_items() {
        configureForReadingMultiple()
        connection.remove(items)
        checkTransactionDidRemoveItems()
        XCTAssertTrue(connection.didWrite)
    }

    func test__connection_async_remove_item() {
        let expectation = self.expectation(description: "Test: \(#function)")
        configureForReadingSingle()
        connection.asyncRemove(item) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidRemoveItem()
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__connection_async_remove_items() {
        let expectation = self.expectation(description: "Test: \(#function)")
        configureForReadingMultiple()
        connection.asyncRemove(items) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidRemoveItems()
        XCTAssertTrue(connection.didAsyncWrite)
    }
}

class Curried_Read_ObjectWithNoMetadataTests: ObjectWithNoMetadataTests {

    // MARK: - Persistable Curried API - Reading

    func test__curried__read_at_index_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(connection.read(TypeUnderTest.readAtIndex(index))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_at_index_with_no_data() {
        XCTAssertFalse(checkTransactionDidReadItem(connection.read(TypeUnderTest.readAtIndex(index))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_at_indexes_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.read(TypeUnderTest.readAtIndexes(indexes))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_at_indexes_with_no_data() {
        XCTAssertFalse(checkTransactionDidReadItems(connection.read(TypeUnderTest.readAtIndexes(indexes))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_by_key_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(connection.read(TypeUnderTest.readByKey(key))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_by_key_with_no_data() {
        XCTAssertFalse(checkTransactionDidReadItem(connection.read(TypeUnderTest.readByKey(key))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_by_keys_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.read(TypeUnderTest.readByKeys(keys))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_by_keys_with_no_data() {
        XCTAssertFalse(checkTransactionDidReadItems(connection.read(TypeUnderTest.readByKeys(keys))))
        XCTAssertTrue(connection.didRead)
    }
}

class Curried_Write_ObjectWithNoMetadataTests: ObjectWithNoMetadataTests {

    func test__curried__write() {
        checkTransactionDidWriteItem(connection.write(item.write()))
        XCTAssertTrue(connection.didWrite)
    }
}

class Persistable_Read_ObjectWithNoMetadataTests: ObjectWithNoMetadataTests {

    // Reading - Internal

    func test__reader__in_transaction_at_index() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(reader.inTransaction(readTransaction, atIndex: index)))
    }

    func test__reader__in_transaction_at_index_2() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let atIndex = reader.inTransactionAtIndex(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(atIndex(index)))
    }

    func test__reader__at_index_in_transaction() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let inTransaction = reader.atIndexInTransaction(index)
        XCTAssertTrue(checkTransactionDidReadItem(inTransaction(readTransaction)))
    }

    func test__reader__at_indexes_in_transaction_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.atIndexesInTransaction(indexes)(readTransaction)))
    }

    func test__reader__at_indexes_in_transaction_with_no_items() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItems(reader.atIndexesInTransaction(indexes)(readTransaction)))
    }

    func test__reader__in_transaction_by_key() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(reader.inTransaction(readTransaction, byKey: key)))
    }

    func test__reader__in_transaction_by_key_2() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let byKey = reader.inTransactionByKey(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(byKey(key)))
    }

    func test__reader__by_key_in_transaction() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let inTransaction = reader.byKeyInTransaction(key)
        XCTAssertTrue(checkTransactionDidReadItem(inTransaction(readTransaction)))
    }

    func test__reader__by_keys_in_transaction_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.byKeysInTransaction(keys)(readTransaction)))
    }

    func test__reader__by_keys_in_transaction_with_items_with_keys() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.byKeysInTransaction()(readTransaction)))
    }

    func test__reader__by_keys_in_transaction_with_no_items() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItems(reader.byKeysInTransaction(keys)(readTransaction)))
    }

    // Reading - With Transaction

    func test__reader_with_transaction__at_index_with_item() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(reader.inTransaction(readTransaction, atIndex: index)))
    }

    func test__reader_with_transaction__at_index_with_no_item() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItem(reader.atIndex(index)))
    }

    func test__reader_with_transaction__at_indexes_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.atIndexes(indexes)))
    }

    func test__reader_with_transaction__at_indexes_with_no_items() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItems(reader.atIndexes(indexes)))
    }

    func test__reader_with_transaction__by_key_with_item() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(reader.inTransaction(readTransaction, atIndex: index)))
    }

    func test__reader_with_transaction__by_key_with_no_item() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItem(reader.byKey(key)))
    }

    func test__reader_with_transaction__by_keys_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.byKeys(keys)))
    }

    func test__reader_with_transaction__by_keys_with_no_items() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItems(reader.byKeys(keys)))
    }

    func test__reader_with_transaction__all_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.all()))
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
    }

    func test__reader_with_transaction__all_with_no_items() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItems(reader.all()))
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
    }

    func test__reader_with_transaction__filter() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let (items, missing) = reader.filterExisting(keys)
        XCTAssertEqual(readTransaction.didReadAtIndexes.first!, indexes.first!)
        XCTAssertEqual(items.map { $0.identifier }, items.prefix(upTo: 1).map { $0.identifier })
        XCTAssertEqual(missing, Array(keys.suffixFrom(1)))
    }

    // Reading - With Connection

    func test__reader_with_connection__at_index_with_item() {
        configureForReadingSingle()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadItem(reader.atIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__at_index_with_no_item() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadItem(reader.atIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__at_indexes_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadItems(reader.atIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__at_indexes_with_no_items() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadItems(reader.atIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__by_key_with_item() {
        configureForReadingSingle()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadItem(reader.byKey(key)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__by_key_with_no_item() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadItem(reader.byKey(key)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__by_keys_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadItems(reader.byKeys(keys)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__by_keys_with_no_items() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadItems(reader.byKeys(keys)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__all_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadItems(reader.all()))
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
    }

    func test__reader_with_connection__all_with_no_items() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadItems(reader.all()))
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
    }

    func test__reader_with_connection__filter() {
        configureForReadingSingle()
        reader = Read(connection)
        let (items, missing) = reader.filterExisting(keys)
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didReadAtIndexes.first!, indexes.first!)
        XCTAssertEqual(items.map { $0.identifier }, items.prefix(upTo: 1).map { $0.identifier })
        XCTAssertEqual(missing, Array(keys.suffixFrom(1)))
    }

}

class Persistable_Write_ObjectWithNoMetadataTests: ObjectWithNoMetadataTests {

    func test__item_persistable__write_using_transaction() {
        checkTransactionDidWriteItem(item.write(writeTransaction))
    }

    func test__item_persistable__write_using_connection() {
        checkTransactionDidWriteItem(item.write(connection))
        XCTAssertTrue(connection.didWrite)
    }

    func test__item_persistable__write_async_using_connection() {
        let expectation = self.expectation(description: "Test: \(#function)")
        var result: TypeUnderTest! = nil

        item.asyncWrite(connection) { tmp in
            result = tmp
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidWriteItem(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__item_persistable__write_using_opertion() {
        let expectation = self.expectation(description: "Test: \(#function)")

        let operation = item.writeOperation(connection)
        operation.completionBlock = {
            expectation.fulfill()
        }

        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 3.0, handler: nil)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
        XCTAssertNil(writeTransaction.didWriteAtIndexes[0].2)
        XCTAssertTrue(connection.didWrite)
    }

    func test__items_persistable__write_using_transaction() {
        checkTransactionDidWriteItems(items.write(writeTransaction))
    }

    func test__items_persistable__write_using_connection() {
        checkTransactionDidWriteItems(items.write(connection))
        XCTAssertTrue(connection.didWrite)
    }

    func test__items_persistable__write_async_using_connection() {
        let expectation = self.expectation(description: "Test: \(#function)")
        var result: [TypeUnderTest] = []

        items.asyncWrite(connection) { tmp in
            result = tmp
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidWriteItems(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__items_persistable__write_using_opertion() {
        let expectation = self.expectation(description: "Test: \(#function)")

        let operation = items.writeOperation(connection)
        operation.completionBlock = {
            expectation.fulfill()
        }

        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 3.0, handler: nil)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sorted(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
        XCTAssertTrue(connection.didWrite)
    }
}

class Persistable_Remove_ObjectWithNoMetadataTests: ObjectWithNoMetadataTests {

    func test__transaction__remove_item() {
        configureForReadingSingle()
        item.remove(writeTransaction)
        checkTransactionDidRemoveItem()
    }

    func test__connection_remove_item() {
        configureForReadingSingle()
        item.remove(connection)
        checkTransactionDidRemoveItem()
        XCTAssertTrue(connection.didWrite)
    }

    func test__connection_async_remove_item() {
        let expectation = self.expectation(description: "Test: \(#function)")
        configureForReadingSingle()
        item.asyncRemove(connection) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidRemoveItem()
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__connection_operation_remove_item() {
        let expectation = self.expectation(description: "Test: \(#function)")
        configureForReadingSingle()
        let operation = item.removeOperation(connection)
        operation.completionBlock = {
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidRemoveItem()
        XCTAssertTrue(connection.didWrite)
    }

    func test__transaction__remove_items() {
        configureForReadingMultiple()
        items.remove(writeTransaction)
        checkTransactionDidRemoveItems()
    }


    func test__connection_remove_items() {
        configureForReadingMultiple()
        items.remove(connection)
        checkTransactionDidRemoveItems()
        XCTAssertTrue(connection.didWrite)
    }

    func test__connection_async_remove_items() {
        let expectation = self.expectation(description: "Test: \(#function)")
        configureForReadingMultiple()
        items.asyncRemove(connection) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidRemoveItems()
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__connection_operation_remove_items() {
        let expectation = self.expectation(description: "Test: \(#function)")
        configureForReadingMultiple()
        let operation = items.removeOperation(connection)
        operation.completionBlock = {
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidRemoveItems()
        XCTAssertTrue(connection.didWrite)
    }
}



