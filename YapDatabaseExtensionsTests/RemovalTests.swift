//
//  RemovalTests.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 09/10/2015.
//  Copyright © 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import XCTest
@testable import YapDatabaseExtensions

class RemovalTests: XCTestCase {

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

    var remover: Remove<TestableConnection>!

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

    // MARK: - Tests

    func test__remover_initializes_with_single_index() {
        remover = Remove(index)

        XCTAssertEqual(remover.indexes.first!, index)
    }

    func test__remover_initializes_with_multiple_indexes() {
        remover = Remove(indexes)

        XCTAssertEqual(remover.indexes, indexes)
    }

    func test__remover_initializes_with_single_item() {
        remover = Remove(item)

        XCTAssertEqual(remover.indexes.first!, index)
    }

    func test__remover_initializes_with_multiple_items() {
        remover = Remove(items)

        XCTAssertEqual(remover.indexes, indexes)
    }

    func test__remove_on_transaction() {
        remover = Remove(item)
        remover.on(writeTransaction)

        XCTAssertNotNil(writeTransaction.didRemoveAtIndex)
        XCTAssertEqual(writeTransaction.didRemoveAtIndex!, index)
    }

    func test__remove_sync() {
        remover = Remove(item)
        remover.sync(connection)

        XCTAssertTrue(connection.didWrite)
        XCTAssertNotNil(writeTransaction.didRemoveAtIndex)
        XCTAssertEqual(writeTransaction.didRemoveAtIndex!, index)
    }

    func test__remove_async() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        remover = Remove(item)
        remover.async(connection, queue: dispatchQueue) {
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertTrue(connection.didAsyncWrite)
        XCTAssertFalse(connection.didWrite)
        XCTAssertNotNil(writeTransaction.didRemoveAtIndex)
        XCTAssertEqual(writeTransaction.didRemoveAtIndex!, index)
    }

    func test__remove_operation() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        remover = Remove(item)
        let operation = remover.operation(connection)
        operation.completionBlock = {
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)

        waitForExpectationsWithTimeout(3.0, handler: nil)
        XCTAssertTrue(connection.didWriteBlockOperation)
        XCTAssertFalse(connection.didWrite)
        XCTAssertFalse(connection.didAsyncWrite)
        XCTAssertNotNil(writeTransaction.didRemoveAtIndex)
        XCTAssertEqual(writeTransaction.didRemoveAtIndex!, index)
    }
}

