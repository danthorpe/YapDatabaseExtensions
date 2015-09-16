//
//  Created by Daniel Thorpe on 22/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import XCTest
import YapDatabase
import YapDatabaseExtensions

class BaseTestCase: XCTestCase {

    let person = Person(id: "user-123", name: "Robbie")
    let barcode: Barcode = .QRCode("I have no idea what the string of a QR Code might look like")
    let product = Product(metadata: Product.Metadata(categoryIdentifier: 1), identifier: "cocoa-123", name: "CocoaPops", barcode: .UPCA(1, 2, 3, 4))

    func people() -> [Person] {
        return [
            Person(id: "beatle-1", name: "John"),
            Person(id: "beatle-2", name: "Paul"),
            Person(id: "beatle-3", name: "George"),
            Person(id: "beatle-4", name: "Ringo")
        ]
    }

    func barcodes() -> Set<Barcode> {
        return [
            .QRCode("I have no idea what the string of a QR Code might look like"),
            .QRCode("This could honestly be what it looks like."),
            .UPCA(1, 2, 3, 5),
            .UPCA(8, 13, 21, 34)
        ]
    }
}

class SynchronousReadWriteTests: BaseTestCase {

    func test_ReadingNonexisting_Object_ByIndex() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let read: Person? = db.readAtIndex(indexForPersistable(person))
        XCTAssertNil(read, "In an empty database, this should return nil.")
    }

    func test_ReadingNonexisting_Value_ByIndex() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let read: Barcode? = db.readAtIndex(indexForPersistable(barcode))
        XCTAssertTrue(read == nil, "In an empty database, this should return nil.")
    }

    func test_ReadingNonexisting_Object_ByKey() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let read: Person? = db.read(keyForPersistable(person))
        XCTAssertNil(read, "In an empty database, this should return nil.")
    }

    func test_ReadingNonexisting_Value_ByKey() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let read: Barcode? = db.read(keyForPersistable(barcode))
        XCTAssertTrue(read == nil, "In an empty database, this should return nil.")
    }

    func test_ReadingNonexisting_Metadata_ByIndex() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let metadata: Product.Metadata? = db.readMetadataAtIndex(indexForPersistable(product))
        XCTAssertTrue(metadata == nil, "In an empty database, this should return nil.")
    }

    func test_ReadingAndWriting_Object() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let saved = db.write(person)
//        validateWrite(db.write(person), original: person, usingDatabase: db)
        XCTAssertEqual(saved.identifier, self.person.identifier)
        XCTAssertEqual(saved.name, self.person.name)
    }

    func test_ReadingAndWriting_Value() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        validateWrite(db.write(barcode), original: barcode, usingDatabase: db)
    }

    func test_ReadingAndWriting_ValueWithValueMetadata() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        validateWrite(db.write(product), original: product, usingDatabase: db)
    }

    func test_ReadingAndWriting_ManyObjects() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)

        let objects = people()
        db.write(objects)

        let read: [Person] = db.readAll()
        XCTAssertEqual(read.count, objects.count)
    }

    func test_ReadingAndWriting_ManyValues() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)

        let values = barcodes()
        db.write(values)

        let read: Set<Barcode> = Set(db.readAll())
        XCTAssertEqual(values, read, "Expecting all keys in collection to return all items.")
    }

    func test_ReadingAnyWriting_ManyObjects_SomeNonexistent() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)

        let objects = people()
        db.write(objects)

        var keys = objects.map(keyForPersistable)
        keys += ["beatle-4", "beatle-5"]

        XCTAssertEqual(keys.count, objects.count + 2, "We should be attempting to read more keys than are stored in the database")

        let read: [Person] = db.read(keys)
        XCTAssertEqual(read.count, objects.count)
    }

    func test_ReadingAnyWriting_ManyValues_SomeNonexistent() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)

        let values = barcodes()
        db.write(values)

        var keys = values.map(keyForPersistable)
        keys += ["some other barcode", "and another one"]

        XCTAssertEqual(keys.count, values.count + 2, "We should be attempting to read more keys than are stored in the database")

        let read: Set<Barcode> = Set(db.read(keys))
        XCTAssertEqual(values, read, "Expecting all keys in collection to return all items.")
    }
}

class AsynchronousWriteTests: BaseTestCase {

    func test_Writing_Object() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of object.")

        db.asyncWrite(person) {
//            validateWrite($0, original: self.person, usingDatabase: db)
            XCTAssertEqual($0.identifier, self.person.identifier)
            XCTAssertEqual($0.name, self.person.name)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_Writing_Value() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of value.")

        db.asyncWrite(barcode) {
            validateWrite($0, original: self.barcode, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_Writing_ValueWithValueMetadata() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of value with value metadata.")

        db.asyncWrite(product) {
            validateWrite($0, original: self.product, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

class AsynchronousReadTests: BaseTestCase {

    func test_Reading_Index_Value() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async reading of value at index.")

        db.write(barcode)
        db.asyncReadAtIndex(indexForPersistable(barcode)) { (saved: Barcode?) -> Void in
            XCTAssertTrue(saved != nil, "There should be an item returned.")
            validateWrite(saved!, original: self.barcode, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_Reading_Index_Object() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async reading of object at index")

        db.write(person)
        db.asyncReadAtIndex(indexForPersistable(person)) { (saved: Person?) -> Void in
            XCTAssertTrue(saved != nil, "There should be an item returned.")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_Reading_Value() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async reading of value by key.")

        db.write(barcode)
        db.asyncRead(keyForPersistable(barcode)) { (read: Barcode?) in
            XCTAssertTrue(read != nil, "There should be an object in the database.")
            XCTAssertEqual(read!, self.barcode, "The value returned from a save value function should equal the argument.")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_Reading_Object() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async reading of object by key.")

        db.write(person)
        db.asyncRead(keyForPersistable(person)) { (read: Person?) in
            XCTAssertTrue(read != nil, "There should be an object in the database.")
            XCTAssertEqual(read!.identifier, self.person.identifier)
            XCTAssertEqual(read!.name, self.person.name)
            expectation.fulfill()            
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_Reading_Values() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async reading of value by key.")

        let values = barcodes()
        db.write(values)

        db.asyncRead(values.map { indexForPersistable($0).key }) { (read: [Barcode]) in
            XCTAssertEqual(values, Set(read), "Expecting all keys in collection to return all items.")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_Reading_Objects() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async reading of object by key.")

        let objects = people()
        db.write(objects)

        db.asyncRead(objects.map(keyForPersistable)) { (read: [Person]) in
            XCTAssertEqual(objects.count, read.count, "Expecting all keys in collection to return all items.")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_ReadingAll_Values() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async reading of all values.")

        let values = barcodes()
        db.write(values)

        db.asyncReadAll() { (read: [Barcode]) in
            XCTAssertEqual(values, Set(read), "Expecting all keys in collection to return all items.")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_ReadingAll_Objects() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async reading of all values.")

        let objects = people()
        db.write(objects)

        db.asyncReadAll() { (read: [Person]) in
            XCTAssertEqual(objects.map { $0.identifier }, read.map { $0.identifier })
            XCTAssertEqual(objects.map { $0.name }, read.map { $0.name })
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

class SynchronousRemoveTests: BaseTestCase {

    func test_RemoveAtIndex() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)

        db.write(barcode)
        XCTAssertEqual((db.readAll() as [Barcode]).count, 1, "There should be one barcodes in the database.")

        db.removeAtIndex(indexForPersistable(barcode))
        XCTAssertEqual((db.readAll() as [Barcode]).count, 0, "There should be no barcodes in the database.")
    }

    func testSynchronous_RemoveAtIndexes() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)

        let _barcodes = barcodes()
        db.write(_barcodes)
        XCTAssertEqual((db.readAll() as [Barcode]).count, _barcodes.count, "There should be one barcodes in the database.")

        db.removeAtIndexes(_barcodes.map(indexForPersistable))
        XCTAssertEqual((db.readAll() as [Barcode]).count, 0, "There should be no barcodes in the database.")
    }

    func test_RemovePersistable() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)

        db.write(barcode)
        XCTAssertEqual((db.readAll() as [Barcode]).count, 1, "There should be one barcodes in the database.")

        db.remove(barcode)
        XCTAssertEqual((db.readAll() as [Barcode]).count, 0, "There should be no barcodes in the database.")
    }

    func test_RemovePersistables() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)

        let _barcodes = barcodes()
        db.write(_barcodes)
        XCTAssertEqual((db.readAll() as [Barcode]).count, _barcodes.count, "There should be one barcodes in the database.")

        db.remove(_barcodes)
        XCTAssertEqual((db.readAll() as [Barcode]).count, 0, "There should be no barcodes in the database.")
    }
}

class AsynchronousRemoveTests: BaseTestCase {

    func test_RemoveAtIndex() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of object.")

        db.write(barcode)
        XCTAssertEqual((db.readAll() as [Barcode]).count, 1, "There should be one barcodes in the database.")

        db.asyncRemoveAtIndex(indexForPersistable(barcode)) {
            XCTAssertEqual((db.readAll() as [Barcode]).count, 0, "There should be no barcodes in the database.")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_RemovePersistable() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of object.")

        db.write(barcode)
        XCTAssertEqual((db.readAll() as [Barcode]).count, 1, "There should be one barcodes in the database.")

        db.asyncRemove(barcode) {
            XCTAssertEqual((db.readAll() as [Barcode]).count, 0, "There should be no barcodes in the database.")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_RemovePersistables() {
        let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of object.")

        let _people = people()
        db.write(_people)
        XCTAssertEqual((db.readAll() as [Person]).count, _people.count, "There should be \(_people.count) Person in the database.")

        db.asyncRemove(_people) {
            XCTAssertEqual((db.readAll() as [Person]).count, 0, "There should be no Person in the database.")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}



