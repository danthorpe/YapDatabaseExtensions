//
//  ValueWithValueMetadataTests.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 09/10/2015.
//  Copyright © 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import XCTest
@testable import YapDatabaseExtensions

class ValueWithValueMetadataTests: XCTestCase {

    typealias TypeUnderTest = Product

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
        item = TypeUnderTest(
            metadata: TypeUnderTest.Metadata(categoryIdentifier: 1),
            identifier: "vodka-123",
            name: "Belvidere",
            barcode: .UPCA(1, 2, 3, 4)
        )
        items = [
            item,
            TypeUnderTest(
                metadata: TypeUnderTest.Metadata(categoryIdentifier: 2),
                identifier: "gin-123",
                name: "Boxer Gin",
                barcode: .UPCA(5, 10, 15, 20)
            ),
            TypeUnderTest(
                metadata: TypeUnderTest.Metadata(categoryIdentifier: 3),
                identifier: "rum-123",
                name: "Mount Gay Rum",
                barcode: .UPCA(12, 24, 39, 48)
            ),
            TypeUnderTest(
                metadata: TypeUnderTest.Metadata(categoryIdentifier: 2),
                identifier: "gin-234",
                name: "Monkey 47",
                barcode: .UPCA(31, 62, 93, 124)
            )
        ]
    }

    func configureForReadingSingle() {
        readTransaction.object = item.encoded
        readTransaction.metadata = item.metadata?.encoded
    }

    func configureForReadingMultiple() {
        readTransaction.objects = items.encoded
        readTransaction.metadatas = items.map { $0.metadata?.encoded }
        readTransaction.keys = keys
    }

    func checkTransactionDidWriteItem(result: TypeUnderTest) {
        XCTAssertEqual(result.identifier, item.identifier)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(TypeUnderTest.decode(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertEqual(TypeUnderTest.MetadataType.decode(writeTransaction.didWriteAtIndexes[0].2), item.metadata)
    }

    func checkTransactionDidWriteItems(result: [TypeUnderTest]) {
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sort(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(Set(result), Set(items))
    }

    func checkTransactionDidReadItem(result: TypeUnderTest?) -> Bool {
        XCTAssertEqual(readTransaction.didReadAtIndex, index)
        guard let result = result else {
            return false
        }
        XCTAssertEqual(readTransaction.didReadMetadataAtIndex, index)
        XCTAssertEqual(result.identifier, item.identifier)
        XCTAssertEqual(result.metadata, item.metadata)
        return true
    }

    func checkTransactionDidReadItems(result: [TypeUnderTest]) -> Bool {
        if result.isEmpty {
            return false
        }
        XCTAssertEqual(Set(readTransaction.didReadAtIndexes), Set(indexes))
        XCTAssertEqual(result.count, items.count)
        return true
    }

    func checkTransactionDidReadMetadataItem(result: TypeUnderTest.MetadataType?) -> Bool {
        XCTAssertNil(readTransaction.didReadAtIndex)
        guard let result = result else {
            return false
        }
        XCTAssertEqual(readTransaction.didReadMetadataAtIndex, index)
        XCTAssertEqual(result, item.metadata)
        return true
    }

    func checkTransactionDidReadMetadataItems(result: [TypeUnderTest.MetadataType]) -> Bool {
        XCTAssertTrue(readTransaction.didReadAtIndexes.isEmpty)
        if result.isEmpty {
            return false
        }
        XCTAssertEqual(Set(readTransaction.didReadMetadataAtIndexes), Set(indexes))
        XCTAssertEqual(result.count, items.count)
        return true
    }
}

// MARK: - Tests

class Base_ValueWithValueMetadataTests: ValueWithValueMetadataTests {

    func test__metadata_is_not_nil() {
        XCTAssertNotNil(item.metadata)
    }
}

class Functional_Read_ValueWithValueMetadataTests: ValueWithValueMetadataTests {

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

class Functional_Read_Metadata_ValueWithValueMetadataTests: ValueWithValueMetadataTests {

    func test__transaction__read_metadata_at_index() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadMetadataItem(readTransaction.readMetadataAtIndex(index)))
    }

    func test__transaction__read_metadata_at_index_no_data() {
        XCTAssertFalse(checkTransactionDidReadMetadataItem(readTransaction.readMetadataAtIndex(index)))
    }

    func test__transaction__read_metadata_at_indexes() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadMetadataItems(readTransaction.readMetadataAtIndexes(indexes)))
    }

    func test__transaction__read_metadata_at_indexes_no_data() {
        XCTAssertFalse(checkTransactionDidReadMetadataItems(readTransaction.readMetadataAtIndexes(indexes)))
    }

    func test__connection__read_metadata_at_index() {
        configureForReadingSingle()
        XCTAssertTrue(checkTransactionDidReadMetadataItem(connection.readMetadataAtIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_metadata_at_index_no_data() {
        XCTAssertFalse(checkTransactionDidReadMetadataItem(connection.readMetadataAtIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_metadata_at_indexes() {
        configureForReadingMultiple()
        XCTAssertTrue(checkTransactionDidReadMetadataItems(connection.readMetadataAtIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }

    func test__connection__read_metadata_at_indexes_no_data() {
        XCTAssertFalse(checkTransactionDidReadMetadataItems(connection.readMetadataAtIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }
}

class Functional_Write_ValueWithValueMetadataTests: ValueWithValueMetadataTests {

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
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")
        connection.asyncWrite(item) { tmp in
            result = tmp
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(3.0, handler: nil)
        checkTransactionDidWriteItem(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__connection__async_write_items() {
        var result: [TypeUnderTest] = []
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")
        connection.asyncWrite(items) { received in
            result = received
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(3.0, handler: nil)
        checkTransactionDidWriteItems(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }
}

class Curried_Read_ValueWithValueMetadataTests: ValueWithValueMetadataTests {

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

class Curried_Write_ValueWithValueMetadataTests: ValueWithValueMetadataTests {

    func test__curried__write() {
        checkTransactionDidWriteItem(connection.write(item.write()))
        XCTAssertTrue(connection.didWrite)
    }
}

class Persistable_Read_ValueWithValueMetadataTests: ValueWithValueMetadataTests {

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
        XCTAssertEqual(items.map { $0.identifier }, items.prefixUpTo(1).map { $0.identifier })
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
        XCTAssertEqual(items.map { $0.identifier }, items.prefixUpTo(1).map { $0.identifier })
        XCTAssertEqual(missing, Array(keys.suffixFrom(1)))
    }

}

class Persistable_Read_Metadata_ValueWithValueMetadataTests: ValueWithValueMetadataTests {

    func test__reader_with_transaction__read_metadata_at_index() {
        configureForReadingSingle()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadMetadataItem(reader.metadataAtIndex(index)))
    }

    func test__reader_with_transaction__read_metadata_at_index_no_data() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadMetadataItem(reader.metadataAtIndex(index)))
    }

    func test__reader_with_transaction__read_metadata_at_indexes() {
        configureForReadingMultiple()
        reader = Read(readTransaction)
        XCTAssertTrue(checkTransactionDidReadMetadataItems(reader.metadataAtIndexes(indexes)))
    }

    func test__reader_with_transaction__read_metadata_at_indexes_no_data() {
        reader = Read(readTransaction)
        XCTAssertFalse(checkTransactionDidReadMetadataItems(reader.metadataAtIndexes(indexes)))
    }

    func test__reader_with_connection__read_metadata_at_index() {
        configureForReadingSingle()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadMetadataItem(reader.metadataAtIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__read_metadata_at_index_no_data() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadMetadataItem(reader.metadataAtIndex(index)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__read_metadata_at_indexes() {
        configureForReadingMultiple()
        reader = Read(connection)
        XCTAssertTrue(checkTransactionDidReadMetadataItems(reader.metadataAtIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }

    func test__reader_with_connection__read_metadata_at_indexes_no_data() {
        reader = Read(connection)
        XCTAssertFalse(checkTransactionDidReadMetadataItems(reader.metadataAtIndexes(indexes)))
        XCTAssertTrue(connection.didRead)
    }
}

class Persistable_Write_ValueWithValueMetadataTests: ValueWithValueMetadataTests {

    func test__item_persistable__write_using_transaction() {
        checkTransactionDidWriteItem(item.write(writeTransaction))
    }

    func test__item_persistable__write_using_connection() {
        checkTransactionDidWriteItem(item.write(connection))
        XCTAssertTrue(connection.didWrite)
    }

    func test__item_persistable__write_async_using_connection() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")
        var result: TypeUnderTest! = nil

        item.asyncWrite(connection) { tmp in
            result = tmp
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(3.0, handler: nil)
        checkTransactionDidWriteItem(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__item_persistable__write_using_opertion() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        let operation = item.writeOperation(connection)
        operation.completionBlock = {
            expectation.fulfill()
        }

        operationQueue.addOperation(operation)
        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes[0].0, index)
        XCTAssertEqual(TypeUnderTest.decode(writeTransaction.didWriteAtIndexes[0].1)!, item)
        XCTAssertEqual(TypeUnderTest.MetadataType.decode(writeTransaction.didWriteAtIndexes[0].2), item.metadata)
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
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")
        var result: [TypeUnderTest] = []
        
        items.asyncWrite(connection) { tmp in
            result = tmp
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(3.0, handler: nil)
        checkTransactionDidWriteItems(result)
        XCTAssertTrue(connection.didAsyncWrite)
    }

    func test__items_persistable__write_using_opertion() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        let operation = items.writeOperation(connection)
        operation.completionBlock = {
            expectation.fulfill()
        }

        operationQueue.addOperation(operation)
        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertFalse(writeTransaction.didWriteAtIndexes.isEmpty)
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.0.key }.sort(), indexes.map { $0.key }.sort())
        XCTAssertEqual(writeTransaction.didWriteAtIndexes.map { $0.2 }.count, items.count)
        XCTAssertTrue(connection.didWrite)
    }
}


