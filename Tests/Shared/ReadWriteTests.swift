//
//  Created by Daniel Thorpe on 22/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import XCTest
import YapDatabase
@testable import YapDatabaseExtensions

class ReadWriteBaseTests: XCTestCase {

    var item: Employee!
    var metadata: NSDate!
    var index: YapDB.Index!
    var key: String!

    var items: [Employee]!
    var metadatas: [NSDate?]!
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
        item = Employee(id: "beatle-1", name: "John")
        metadata = NSDate()
        items = [
            item,
            Employee(id: "beatle-2", name: "Paul"),
            Employee(id: "beatle-3", name: "George"),
            Employee(id: "beatle-4", name: "Ringo")
        ]
        metadatas = [
            metadata,
            NSDate(),
            NSDate(),
            NSDate()
        ]
    }

    func writeItemsToDatabase(db: YapDatabase) {
        db.makeNewConnection().writeWithMetadata(zipToWrite(items, metadatas))
    }
}

class ReadTests: ReadWriteBaseTests {

    var reader: Read<Employee, YapDatabase>!

    func test__initialize_with_transaction() {
        let db = YapDB.testDatabase()
        let connection = db.makeNewConnection()
        connection.readWithBlock { transaction in
            self.reader = Read(transaction)
            XCTAssertNotNil(self.reader)
        }
    }

    func test__initialize_with_connection() {
        let db = YapDB.testDatabase()
        reader = Read(db.makeNewConnection())
        XCTAssertNotNil(reader)
        XCTAssertNil(reader.transaction)
        XCTAssertNotNil(reader.connection)
    }

    func test__initialize_with_database() {
        let db = YapDB.testDatabase()
        reader = Read(db)
        XCTAssertNotNil(reader)
        XCTAssertNil(reader.transaction)
        XCTAssertNotNil(reader.connection)
    }

    func test__getting_reader_from_persistable_with_transaction() {
        let db = YapDB.testDatabase()
        let connection = db.makeNewConnection()
        connection.readWithBlock { transaction in
            self.reader = Employee.read(transaction)
            XCTAssertNotNil(self.reader)
        }
    }

    func test__getting_reader_from_persistable_with_connection() {
        let db = YapDB.testDatabase()
        reader = Employee.read(db.newConnection())
        XCTAssertNotNil(reader)
        XCTAssertNil(reader.transaction)
        XCTAssertNotNil(reader.connection)
    }

    func test__getting_reader_from_persistable_with_database() {
        let db = YapDB.testDatabase()
        reader = Employee.read(db)
        XCTAssertNotNil(reader)
        XCTAssertNil(reader.transaction)
        XCTAssertNotNil(reader.connection)
    }
}

/*
class RemoveTests: ReadWriteBaseTests {

    var remover: Remove<YapDatabase>!

    func test__initializing_with_single_item() {
        remover = item.remove
        XCTAssertNotNil(remover)
        XCTAssertEqual(remover.indexes.first!, index)
    }

    func test__initializing_with_multiple_items() {
        remover = items.remove
        XCTAssertNotNil(remover)
        XCTAssertEqual(remover.indexes, indexes)
    }

    func test__initializing_with_single_index() {
        remover = Employee.remove(index)
        XCTAssertNotNil(remover)
        XCTAssertEqual(remover.indexes.first!, index)
    }

    func test__initializing_with_single_key() {
        remover = Employee.remove(key)
        XCTAssertNotNil(remover)
        XCTAssertEqual(remover.indexes.first!, index)
    }

    func test__initializing_with_multiple_indexes() {
        remover = indexes.remove
        XCTAssertNotNil(remover)
        XCTAssertEqual(remover.indexes, indexes)
    }
}
*/


