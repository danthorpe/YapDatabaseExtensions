//
//  YapDatabaseExtensionsTests.swift
//  YapDatabaseExtensionsTests
//
//  Created by Daniel Thorpe on 10/06/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import XCTest
import ValueCoding
import YapDatabase
@testable import YapDatabaseExtensions

class YapDatabaseExtensionsTests: XCTestCase {

    func test_ViewRegistration_NotRegisteredInEmptyDatabase() {
        let db = YapDB.testDatabase()
        let fetch: YapDB.Fetch = products()
        XCTAssertFalse(fetch.isRegisteredInDatabase(db), "Extension should not be registered in fresh database.")
    }

    func test_ViewRegistration_RegistersCorrectly() {
        let db = YapDB.testDatabase()
        let fetch: YapDB.Fetch = products()
        fetch.registerInDatabase(db)
        XCTAssertTrue(fetch.isRegisteredInDatabase(db), "Extension should be registered in database.")
    }

    func test_AfterRegistration_ViewIsAccessible() {
        let db = YapDB.testDatabase()
        let fetch: YapDB.Fetch = products()
        fetch.registerInDatabase(db)
        db.newConnection().read { transaction in
            XCTAssertNotNil(transaction.ext(fetch.name) as? YapDatabaseViewTransaction, "The view should be accessible inside a read transaction.")
        }
    }

    func test_YapDBIndex_EncodingAndDecoding() {
        let index = YapDB.Index(collection: "Foo", key: "Bar")
        let _index = YapDB.Index.decode(index.encoded)
        XCTAssertTrue(_index != nil, "Unarchived archive should not be nil")
        XCTAssertEqual(index, _index!, "Unarchived archive should equal the original.")
    }
}

class PersistableTests: XCTestCase {

    func test__indexes_from_keys() {
        let keys = [ "beatle-1", "beatle-2", "beatle-3", "beatle-4", "beatle-2" ]
        let indexes = Person.indexesWithKeys(keys)
        XCTAssertEqual(indexes.count, 4)
    }
}

class YapDatabaseReadTransactionTests: ReadWriteBaseTests {

    func test__keys_in_collection_returns_empty_with_empty_db() {
        let db = YapDB.testDatabase()
        let keys = db.makeNewConnection().read { $0.keysInCollection(Employee.collection) }
        XCTAssertNotNil(keys)
        XCTAssertTrue(keys.isEmpty)
    }

    func test__keys_in_collection_returns_all_keys_when_non_empty_db() {
        let db = YapDB.testDatabase()
        writeItemsToDatabase(db)
        let keys = db.makeNewConnection().read { $0.keysInCollection(Employee.collection) }
        XCTAssertNotNil(keys)
        XCTAssertEqual(keys.sorted(), items.map { $0.key }.sorted())
    }

    func test__read_at_index_returns_nil_with_empty_db() {
        let db = YapDB.testDatabase()
        let object = db.makeNewConnection().read { $0.readAtIndex(self.index) }
        XCTAssertNil(object)
    }

    func test__read_at_index_returns_object_when_non_empty_db() {
        let db = YapDB.testDatabase()
        writeItemsToDatabase(db)
        let object = db.makeNewConnection().read { $0.readAtIndex(self.index) }
        XCTAssertNotNil(object as? Employee)
        XCTAssertEqual((object as! Employee).identifier, item.identifier)
    }

    func test__read_metadata_at_index_returns_nil_with_empty_db() {
        let db = YapDB.testDatabase()
        let metadata = db.makeNewConnection().read { $0.readMetadataAtIndex(self.index) }
        XCTAssertNil(metadata)
    }

    func test__read_metadata_at_index_returns_object_when_non_empty_db() {
        let db = YapDB.testDatabase()
        writeItemsToDatabase(db)
        let metadata = db.makeNewConnection().read { $0.readMetadataAtIndex(self.index) }
        XCTAssertNotNil(metadata as? NSDate)
    }
}

class YapDatabaseReadWriteTransactionTests: ReadWriteBaseTests {

    func test__write_at_index_without_metadata() {
        let db = YapDB.testDatabase()
        db.makeNewConnection().readWrite { transaction in
            transaction.writeAtIndex(self.index, object: self.item)
        }
        let written = Employee.read(db).atIndex(index)
        XCTAssertNotNil(written)
        XCTAssertEqual(written!.identifier, item.identifier)
    }

    func test__write_at_index_with_metadata() {
        let db = YapDB.testDatabase()
        db.makeNewConnection().readWrite { transaction in
            transaction.writeAtIndex(self.index, object: self.item, metadata: self.metadata)
        }
        let written: YapItem<Employee, NSDate>? = Employee.read(db).withMetadataAtIndex(index)
        XCTAssertNotNil(written)
        XCTAssertNotNil(written!.metadata)
        XCTAssertEqual(written!.value.identifier, item.identifier)
    }

    func test__remove_at_indexes() {
        let db = YapDB.testDatabase()

        db.makeNewConnection().write(items)
        XCTAssertNotNil(Employee.read(db).atIndex(index))

        db.makeNewConnection().readWrite { transaction in
            transaction.removeAtIndexes(self.indexes)
        }

        XCTAssertNil(Employee.read(db).atIndex(index))
    }
}

class YapDatabaseConnectionTests: ReadWriteBaseTests {

    var dispatchQueue: DispatchQueue!
    var operationQueue: OperationQueue!

    override func setUp() {
        super.setUp()
        dispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.`default`)
        operationQueue = OperationQueue()
    }

    func test__async_read() {
        let db = YapDB.testDatabase()
        let expectation = self.expectation(description: "Test: \(#function)")

        db.makeNewConnection().write(item)
        XCTAssertNotNil(Employee.read(db).atIndex(index))

        var received: Employee? = .none
        db.newConnection().asyncRead({ transaction -> Employee? in
            return transaction.readAtIndex(self.index) as? Employee
        }, queue: dispatchQueue) { (result: Employee?) in
            received = result
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0, handler: nil)

        XCTAssertNotNil(received)
    }

    func test__async_write() {
        let db = YapDB.testDatabase()
        let expectation = self.expectation(description: "Test: \(#function)")

        var written: Employee? = .none
        db.makeNewConnection().asyncWrite({ transaction -> Employee? in
            transaction.writeAtIndex(self.index, object: self.item, metadata: self.metadata)
            return self.item
        }, queue: dispatchQueue) { (result: Employee?) in
            written = result
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0, handler: nil)

        XCTAssertNotNil(written)
        XCTAssertNotNil(Employee.read(db).atIndex(index))
    }

    func test__writeBlockOperation() {
        let db = YapDB.testDatabase()
        let expectation = self.expectation(description: "Test: \(#function)")

        var didExecuteWithTransaction = false
        let operation = db.makeNewConnection().writeBlockOperation { transaction in
            didExecuteWithTransaction = true
        }
        operation.completionBlock = { expectation.fulfill() }

        operationQueue.addOperation(operation)

        waitForExpectations(timeout: 3.0, handler: nil)
        XCTAssertTrue(operation.isFinished)
        XCTAssertTrue(didExecuteWithTransaction)
    }
}

class ValueCodingTests: XCTestCase {

    var item: Product!
    var metadata: Product.Metadata!
    var index: YapDB.Index!
    var key: String!

    var items: [Product]!
    var metadatas: [Product.Metadata?]!
    var indexes: [YapDB.Index]!
    var keys: [String]!

    override func setUp() {
        super.setUp()
        createPersistables()
        index = item.index
        key = item.key

        indexes = items.map { $0.index }
        keys = items.map { $0.key }
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
        super.tearDown()
    }

    func createPersistables() {
        item = Product(
            identifier: "vodka-123",
            name: "Belvidere",
            barcode: .upca(1, 2, 3, 4)
        )
        metadata = Product.Metadata(categoryIdentifier: 1)
        items = [
            item,
            Product(
                identifier: "gin-123",
                name: "Boxer Gin",
                barcode: .upca(5, 10, 15, 20)
            ),
            Product(
                identifier: "rum-123",
                name: "Mount Gay Rum",
                barcode: .upca(12, 24, 39, 48)
            ),
            Product(
                identifier: "gin-234",
                name: "Monkey 47",
                barcode: .upca(31, 62, 93, 124)
            )
        ]
        metadatas = [
            metadata,
            Product.Metadata(categoryIdentifier: 2),
            Product.Metadata(categoryIdentifier: 3),
            Product.Metadata(categoryIdentifier: 2)
        ]
    }

    func test__index_is_hashable() {
        let byHashes: [YapDB.Index: Product] = items.reduce(Dictionary<YapDB.Index, Product>()) { (dictionary, product) in
            var dictionary = dictionary
            dictionary.updateValue(product, forKey: product.index)
            return dictionary
        }
        XCTAssertEqual(byHashes.count, items.count)
    }

    func test__index_is_codable() {
        let db = YapDB.testDatabase()
        db.makeNewConnection().readWrite { transaction in
            transaction.setObject(self.index.encoded, forKey: "test-index", inCollection: "test-index-collection")
        }

        let unarchived = YapDB.Index.decode(db.makeNewConnection().read { $0.object(forKey: "test-index", inCollection: "test-index-collection") })
        XCTAssertNotNil(unarchived)
        XCTAssertEqual(unarchived!, index)
    }

    func test__index_for_persistable() {
        XCTAssertEqual(indexForPersistable(item), index)
    }
}

