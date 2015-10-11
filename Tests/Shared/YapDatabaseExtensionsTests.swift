//
//  YapDatabaseExtensionsTests.swift
//  YapDatabaseExtensionsTests
//
//  Created by Daniel Thorpe on 10/06/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import XCTest
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
        let _index = YapDB.Index(index.archive)
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
        XCTAssertEqual(keys.sort(), items.map { $0.key }.sort())
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
        db.makeNewConnection().readWriteWithBlock { transaction in
            transaction.writeAtIndex(self.index, object: self.item)
        }
        let written = Employee.read(db).atIndex(index)
        XCTAssertNotNil(written)
        XCTAssertNil(written!.metadata)
        XCTAssertEqual(written!.identifier, item.identifier)
    }

    func test__write_at_index_with_metadata() {
        let db = YapDB.testDatabase()
        db.makeNewConnection().readWriteWithBlock { transaction in
            transaction.writeAtIndex(self.index, object: self.item, metadata: self.item.metadata)
        }
        let written = Employee.read(db).atIndex(index)
        XCTAssertNotNil(written)
        XCTAssertNotNil(written!.metadata)
        XCTAssertEqual(written!.identifier, item.identifier)
    }

    func test__remove_at_indexes() {
        let db = YapDB.testDatabase()

        items.write.sync(db.makeNewConnection())
        XCTAssertNotNil(Employee.read(db).atIndex(index))

        db.makeNewConnection().readWriteWithBlock { transaction in
            transaction.removeAtIndexes(self.indexes)
        }

        XCTAssertNil(Employee.read(db).atIndex(index))
    }
}

class YapDatabaseConnectionTests: ReadWriteBaseTests {

    var dispatchQueue: dispatch_queue_t!
    var operationQueue: NSOperationQueue!

    override func setUp() {
        super.setUp()
        dispatchQueue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)
        operationQueue = NSOperationQueue()
    }

    func test__async_read() {
        let db = YapDB.testDatabase()
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        item.write.sync(db.makeNewConnection())
        XCTAssertNotNil(Employee.read(db).atIndex(index))

        var received: Employee? = .None
        db.newConnection().asyncRead({ transaction -> Employee? in
            return transaction.readAtIndex(self.index) as? Employee
        }, queue: dispatchQueue) { (result: Employee?) in
            received = result
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(3.0, handler: nil)

        XCTAssertNotNil(received)
    }

    func test__async_write() {
        let db = YapDB.testDatabase()
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        var written: Employee? = .None
        db.makeNewConnection().asyncWrite({ transaction -> Employee? in
            transaction.writeAtIndex(self.index, object: self.item, metadata: self.item.metadata)
            return self.item
        }, queue: dispatchQueue) { (result: Employee?) in
            written = result
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(3.0, handler: nil)

        XCTAssertNotNil(written)
        XCTAssertNotNil(Employee.read(db).atIndex(index))
    }

    func test__writeBlockOperation() {
        let db = YapDB.testDatabase()
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        var didExecuteWithTransaction = false
        let operation = db.makeNewConnection().writeBlockOperation { transaction in
            didExecuteWithTransaction = true
            expectation.fulfill()
        }

        operationQueue.addOperation(operation)

        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertTrue(didExecuteWithTransaction)
    }
}

class SaveableTests: XCTestCase {

    var item: Product!
    var index: YapDB.Index!
    var key: String!

    var items: [Product]!
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
        index = nil
        key = nil
        items = nil
        indexes = nil
        keys = nil
        super.tearDown()
    }

    func createPersistables() {
        item = Product(
            metadata: Product.Metadata(categoryIdentifier: 1),
            identifier: "vodka-123",
            name: "Belvidere",
            barcode: .UPCA(1, 2, 3, 4)
        )
        items = [
            item,
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
    }

    func test__single_archiving() {
        let unarchived = Product.unarchive(Product.archive(item))
        XCTAssertNotNil(unarchived)
        XCTAssertEqual(unarchived!, item)
    }

    func test__multiple_archiving() {
        let unarchived = Product.unarchive(Product.archive(items))
        XCTAssertEqual(unarchived, items)
    }

    func test__initializing_with_nil() {
        let empty: AnyObject? = .None
        XCTAssertNil(Barcode(empty))
    }

    func test__get_values_from_sequence_of_archivers() {
        let archives = Product.archive(items) as! [Product.ArchiverType]
        XCTAssertEqual(archives.values, items)
    }

    func test__index_is_hashable() {
        let byHashes: [YapDB.Index: Product] = items.reduce(Dictionary<YapDB.Index, Product>()) { (var dic, product) in
            dic.updateValue(product, forKey: product.index)
            return dic
        }
        XCTAssertEqual(byHashes.count, items.count)
    }

    func test__index_is_saveable() {
        let db = YapDB.testDatabase()
        db.makeNewConnection().readWriteWithBlock { transaction in
            transaction.setObject(self.index.archive, forKey: "test-index", inCollection: "test-index-collection")
        }

        let unarchived = YapDB.Index(db.makeNewConnection().read { $0.objectForKey("test-index", inCollection: "test-index-collection") })
        XCTAssertNotNil(unarchived)
        XCTAssertEqual(unarchived!, index)
    }

    func test__index_for_persistable() {
        XCTAssertEqual(indexForPersistable(item), index)
    }
}

