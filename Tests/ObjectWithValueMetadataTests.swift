//
//  ObjectWithValueMetadataTests.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 09/10/2015.
//  Copyright © 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import XCTest
@testable import YapDatabaseExtensions

class ObjectWithValueMetadataTests: XCTestCase {

    typealias TypeUnderTest = Manager
    typealias MetadataTypeUnderTest = Manager.Metadata

    var item: TypeUnderTest!
    var metadata: MetadataTypeUnderTest!
    var index: YapDB.Index!
    var key: String!

    var items: [TypeUnderTest]!
    var metadatas: [MetadataTypeUnderTest?]!
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
        metadata = nil
        index = nil
        key = nil
        items = nil
        metadatas = nil
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
        metadata = MetadataTypeUnderTest(numberOfDirectReports: 4)
        items = [
            item,
            TypeUnderTest(id: "beatle-2", name: "Paul"),
            TypeUnderTest(id: "beatle-3", name: "George"),
            TypeUnderTest(id: "beatle-4", name: "Ringo")
        ]
        metadatas = [
            metadata,
            MetadataTypeUnderTest(numberOfDirectReports: 3),
            MetadataTypeUnderTest(numberOfDirectReports: 2),
            MetadataTypeUnderTest(numberOfDirectReports: 1)
        ]
    }

    func configureForReadingSingle() {
        readTransaction.object = item
        readTransaction.metadata = metadata?.encoded
    }

    func configureForReadingMultiple() {
        readTransaction.objects = items
        readTransaction.metadatas = metadatas.map { $0?.encoded }
        readTransaction.keys = keys
    }

    func checkTransactionDidWriteItem(_ result: YapItem<TypeUnderTest, MetadataTypeUnderTest>) {
        XCTAssertEqual(result.value.identifier, item.identifier)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
        XCTAssertEqual(MetadataTypeUnderTest.decode(writeTransaction.didWriteAtIndexes[0].2), metadata)
    }

    func checkTransactionDidWriteItems(_ result: [YapItem<TypeUnderTest, MetadataTypeUnderTest>]) {
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sorted(), indexes.map { $0.key }.sorted())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(Set(result.map({$0.value})), Set(items))
    }

    func checkTransactionDidReadItem(_ result: YapItem<TypeUnderTest, MetadataTypeUnderTest>?) -> Bool {
        guard let result = result else {
            return false
        }
        XCTAssertEqual(readTransaction.didReadAtIndex, index)
        XCTAssertEqual(result.value.identifier, item.identifier)
        XCTAssertEqual(readTransaction.didReadMetadataAtIndex, index)
        XCTAssertEqual(result.metadata, metadata)
        return true
    }

    func checkTransactionDidReadItems(_ result: [YapItem<TypeUnderTest, MetadataTypeUnderTest>?]) -> Bool {
        if result.flatMap({$0}).isEmpty {
            return false
        }
        XCTAssertEqual(Set(readTransaction.didReadAtIndexes), Set(indexes))
        XCTAssertEqual(result.flatMap({$0}).count, items.count)
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

// MARK: - Tests

class Base_ObjectWithValueMetadataTests: ObjectWithValueMetadataTests {

    func test__metadata_is_not_nil() {
        XCTAssertNotNil(metadata)
    }
}

class Functional_Read_ObjectWithValueMetadataTests: ObjectWithValueMetadataTests {

    // Functional API - ReadTransactionType - Reading

    func test__transaction__read_at_index_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(readTransaction.readWithMetadataAtIndex(index)))
    }

    func test__transaction__read_at_index_without_data() {
        XCTAssertFalse(checkTransactionDidReadItem(readTransaction.readWithMetadataAtIndex(index)))
    }

    func test__transaction__read_at_indexes_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(readTransaction.readWithMetadataAtIndexes(indexes)))
    }

    func test__transaction__read_at_indexes_with_data_2() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(readTransaction.readWithMetadataAtIndexes(Set(indexes))))
    }

    func test__transaction__read_at_indexes_without_data() {
        XCTAssertFalse(checkTransactionDidReadItems(readTransaction.readWithMetadataAtIndexes(indexes)))
    }

    func test__transaction__read_by_key_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(readTransaction.readWithMetadataByKey(key)))
    }

    func test__transaction__read_by_key_without_data() {
        XCTAssertFalse(checkTransactionDidReadItem(readTransaction.readWithMetadataByKey(key)))
    }

    func test__transaction__read_by_keys_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(readTransaction.readWithMetadataByKeys(keys)))
    }

    func test__transaction__read_by_keys_with_data_2() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(readTransaction.readWithMetadataByKeys(Set(keys))))
    }

    func test__transaction__read_by_keys_without_data() {
        XCTAssertFalse(checkTransactionDidReadItems(readTransaction.readWithMetadataByKeys(keys)))
    }

    func test__transaction__read_all_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(readTransaction.readWithMetadataAll()))
    }

    // Functional API - ConnectionType - Reading

    func test__connection__read_at_index_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(connection.readWithMetadataAtIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_at_index_without_data() {
        XCTAssertFalse(checkTransactionDidReadItem(connection.readWithMetadataAtIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_at_indexes_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.readWithMetadataAtIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_at_indexes_with_data_2() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.readWithMetadataAtIndexes(Set(indexes))))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_at_indexes_without_data() {
        XCTAssertFalse(checkTransactionDidReadItems(connection.readWithMetadataAtIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_by_key_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(connection.readWithMetadataByKey(key)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_by_key_without_data() {
        XCTAssertFalse(checkTransactionDidReadItem(connection.readWithMetadataByKey(key)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_by_keys_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.readWithMetadataByKeys(keys)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_by_keys_with_data_2() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.readWithMetadataByKeys(Set(keys))))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_by_keys_without_data() {
        XCTAssertFalse(checkTransactionDidReadItems(connection.readWithMetadataByKeys(keys)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_all_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.readWithMetadataAll()))
        XCTAssertTrue(connection.didRead)
    }
}

class Functional_Write_ObjectWithValueMetadataTests: ObjectWithValueMetadataTests {

    func test__transaction__write_item() {
        checkTransactionDidWriteItem(writeTransaction.writeWithMetadata(YapItem(item, metadata)))
    }

    func test__transaction__write_items() {
        checkTransactionDidWriteItems(writeTransaction.writeWithMetadata(items.yapItems(with: metadatas)))
    }

    // MARK: - Functional API - Connection - Writing

    func test__connection__write_item() {
        checkTransactionDidWriteItem(connection.writeWithMetadata(YapItem(item, metadata)))
        XCTAssertTrue(connection.didWrite)
    }

    func test__connection__write_items() {
        checkTransactionDidWriteItems(connection.writeWithMetadata(items.yapItems(with: metadatas)))
        XCTAssertTrue(connection.didWrite)
    }

    func test__connection__async_write_item() {
        var result: YapItem<TypeUnderTest, MetadataTypeUnderTest>!
        let expectation = self.expectation(description: "Test: \(#function)")
        connection.asyncWriteWithMetadata(YapItem(item, metadata)) { tmp in
            result = tmp
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidWriteItem(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__connection__async_write_items() {
        var result: [YapItem<TypeUnderTest, MetadataTypeUnderTest>] = []
        let expectation = self.expectation(description: "Test: \(#function)")
        connection.asyncWriteWithMetadata(items.yapItems(with: metadatas)) { received in
            result = received
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidWriteItems(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }
}

class Functional_Remove_ObjectWithValueMetadataTests: ObjectWithValueMetadataTests {

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

class Curried_Read_ObjectWithValueMetadataTests: ObjectWithValueMetadataTests {

    // MARK: - Persistable Curried API - Reading

    func test__curried__read_at_index_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(connection.read(TypeUnderTest.readWithMetadataAtIndex(index))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_at_index_with_no_data() {
        XCTAssertFalse(checkTransactionDidReadItem(connection.read(TypeUnderTest.readWithMetadataAtIndex(index))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_at_indexes_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.read(TypeUnderTest.readWithMetadataAtIndexes(indexes))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_at_indexes_with_no_data() {
        XCTAssertFalse(checkTransactionDidReadItems(connection.read(TypeUnderTest.readWithMetadataAtIndexes(indexes))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_by_key_with_data() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadItem(connection.read(TypeUnderTest.readWithMetadataByKey(key))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_by_key_with_no_data() {
        XCTAssertFalse(checkTransactionDidReadItem(connection.read(TypeUnderTest.readWithMetadataByKey(key))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_by_keys_with_data() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadItems(connection.read(TypeUnderTest.readWithMetadataByKeys(keys))))
        XCTAssertTrue(connection.didRead)
    }

    func test__curried__read_by_keys_with_no_data() {
        XCTAssertFalse(checkTransactionDidReadItems(connection.read(TypeUnderTest.readWithMetadataByKeys(keys))))
        XCTAssertTrue(connection.didRead)
    }
}

class Curried_Write_ObjectWithValueMetadataTests: ObjectWithValueMetadataTests {

    func test__curried__write() {
        checkTransactionDidWriteItem(connection.write(item.writeWithMetadata(metadata)))
        XCTAssertTrue(connection.didWrite)
    }
}

class Persistable_Read_ObjectWithValueMetadataTests: ObjectWithValueMetadataTests {

    // Reading - Internal

    func test__reader__in_transaction_at_index() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(reader.withMetadataInTransaction(readTransaction, atIndex: index)))
    }

    func test__reader__in_transaction_at_index_2() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let atIndex: (YapDB.Index) -> YapItem<TypeUnderTest, MetadataTypeUnderTest>? = reader.withMetadataInTransactionAtIndex(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(atIndex(index)))
    }

    func test__reader__at_index_in_transaction() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let inTransaction: (TestableReadTransaction) -> YapItem<TypeUnderTest, MetadataTypeUnderTest>? = reader.withMetadataAtIndexInTransaction(index)
        XCTAssertTrue(checkTransactionDidReadItem(inTransaction(readTransaction)))
    }

    func test__reader__at_indexes_in_transaction_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.withMetadataAtIndexesInTransaction(indexes)(readTransaction)))
    }

    func test__reader__at_indexes_in_transaction_with_no_items() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItems(reader.withMetadataAtIndexesInTransaction(indexes)(readTransaction)))
    }

    func test__reader__in_transaction_by_key() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(reader.withMetadataInTransaction(readTransaction, byKey: key)))
    }

    func test__reader__in_transaction_by_key_2() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let byKey: (String) -> YapItem<TypeUnderTest, MetadataTypeUnderTest>? = reader.withMetadataInTransactionByKey(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(byKey(key)))
    }

    func test__reader__by_key_in_transaction() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let inTransaction: (TestableReadTransaction) -> YapItem<TypeUnderTest, MetadataTypeUnderTest>? = reader.withMetadataByKeyInTransaction(key)
        XCTAssertTrue(checkTransactionDidReadItem(inTransaction(readTransaction)))
    }

    func test__reader__by_keys_in_transaction_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.withMetadataByKeysInTransaction(keys)(readTransaction)))
    }

    func test__reader__by_keys_in_transaction_with_items_with_keys() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.withMetadataByKeysInTransaction()(readTransaction)))
    }

    func test__reader__by_keys_in_transaction_with_no_items() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItems(reader.withMetadataByKeysInTransaction(keys)(readTransaction)))
    }

    // Reading - With Transaction

    func test__reader_with_transaction__at_index_with_item() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(reader.withMetadataInTransaction(readTransaction, atIndex: index)))
    }

    func test__reader_with_transaction__at_index_with_no_item() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItem(reader.withMetadataAtIndex(index)))
    }

    func test__reader_with_transaction__at_indexes_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.withMetadataAtIndexes(indexes)))
    }

    func test__reader_with_transaction__at_indexes_with_no_items() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItems(reader.withMetadataAtIndexes(indexes)))
    }

    func test__reader_with_transaction__by_key_with_item() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItem(reader.withMetadataInTransaction(readTransaction, atIndex: index)))
    }

    func test__reader_with_transaction__by_key_with_no_item() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItem(reader.withMetadataByKey(key)))
    }

    func test__reader_with_transaction__by_keys_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.withMetadataByKeys(keys)))
    }

    func test__reader_with_transaction__by_keys_with_no_items() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItems(reader.withMetadataByKeys(keys)))
    }

    func test__reader_with_transaction__all_with_items() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadItems(reader.withMetadataAll()))
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
    }

    func test__reader_with_transaction__all_with_no_items() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadItems(reader.withMetadataAll()))
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
    }

    func test__reader_with_transaction__filter() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        let (items, missing): ([YapItem<TypeUnderTest, MetadataTypeUnderTest>], [String]) = reader.withMetadataFilterExisting(keys)
        XCTAssertEqual(readTransaction.didReadAtIndexes.first!, indexes.first!)
        XCTAssertEqual(items.map { $0.value.identifier }, items.prefix(upTo: 1).map { $0.value.identifier })
        XCTAssertEqual(missing, Array(keys.suffix(from: 1)))
    }

    // Reading - With Connection

    func test__reader_with_connection__at_index_with_item() {
        configureForReadingSingle()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadItem(reader.withMetadataAtIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__at_index_with_no_item() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadItem(reader.withMetadataAtIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__at_indexes_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadItems(reader.withMetadataAtIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__at_indexes_with_no_items() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadItems(reader.withMetadataAtIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__by_key_with_item() {
        configureForReadingSingle()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadItem(reader.withMetadataByKey(key)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__by_key_with_no_item() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadItem(reader.withMetadataByKey(key)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__by_keys_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadItems(reader.withMetadataByKeys(keys)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__by_keys_with_no_items() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadItems(reader.withMetadataByKeys(keys)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__all_with_items() {
        configureForReadingMultiple()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadItems(reader.withMetadataAll()))
        XCTAssertTrue(connection.didRead)
        XCTAssertEqual(readTransaction.didKeysInCollection, TypeUnderTest.collection)
    }

    func test__reader_with_connection__all_with_no_items() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadItems(reader.withMetadataAll()))
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
        XCTAssertEqual(missing, Array(keys.suffix(from: 1)))
    }

}

class Persistable_Write_ObjectWithValueMetadataTests: ObjectWithValueMetadataTests {

    func test__item_persistable__write_using_transaction() {
        checkTransactionDidWriteItem(item.writeWithMetadata(writeTransaction, metadata: metadata))
    }

    func test__item_persistable__write_using_connection() {
        checkTransactionDidWriteItem(item.writeWithMetadata(connection, metadata: metadata))
        XCTAssertTrue(connection.didWrite)
    }

    func test__item_persistable__write_async_using_connection() {
        let expectation = self.expectation(description: "Test: \(#function)")
        var result: YapItem<TypeUnderTest, MetadataTypeUnderTest>! = nil

        item.asyncWriteWithMetadata(connection, metadata: metadata) { tmp in
            result = tmp
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        checkTransactionDidWriteItem(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__item_persistable__write_using_opertion() {
        let expectation = self.expectation(description: "Test: \(#function)")

        let operation = item.writeWithMetadataOperation(connection, metadata: metadata)
        operation.completionBlock = {
            expectation.fulfill()
        }

        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 3.0, handler: nil)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].1.identifier, item.identifier)
        XCTAssertEqual(MetadataTypeUnderTest.decode(writeTransaction.didWriteAtIndexes[0].2), metadata)
        XCTAssertTrue(connection.didWrite)
    }

    func test__items_persistable__write_using_transaction() {
        checkTransactionDidWriteItems(items.writeWithMetadata(writeTransaction, metadata: metadatas))
    }

    func test__items_persistable__write_using_connection() {
        checkTransactionDidWriteItems(items.writeWithMetadata(connection, metadata: metadatas))
        XCTAssertTrue(connection.didWrite)
    }

    func test__items_persistable__write_async_using_connection() {
        let expectation = self.expectation(description: "Test: \(#function)")
        var result: [YapItem<TypeUnderTest, MetadataTypeUnderTest>] = []
        
        items.asyncWriteWithMetadata(connection, metadata: metadatas) { tmp in
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
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sorted(), indexes.map { $0.key }.sorted())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
        XCTAssertTrue(connection.didWrite)
    }
}

class Persistable_Remove_ObjectWithValueMetadataTests: ObjectWithValueMetadataTests {

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


