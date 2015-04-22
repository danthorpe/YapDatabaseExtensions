//
//  SwiftTaskTests.swift
//  YapDBExtensionsMobile
//
//  Created by Daniel Thorpe on 15/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import XCTest
import SwiftTask
import YapDatabase
import YapDatabaseExtensions
import YapDBExtensionsMobile


extension AsynchronousWriteTests {

    func test_ReadingAndWriting_Object_SwiftTask() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of object.")

        (db.asyncWrite(person) as Task<Void, Person, Void>).success { saved -> Void in
            validateWrite(saved, self.person, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_ReadingAndWriting_Value_SwiftTask() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of value.")

        (db.asyncWrite(barcode) as Task<Void, Barcode, Void>).success { saved -> Void in
            validateWrite(saved, self.barcode, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_ReadingAndWriting_ValueWithValueMetadata_SwiftTask() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of value with value metadata.")

        (db.asyncWrite(product) as Task<Void, Product, Void>).success { saved -> Void in
            validateWrite(saved, self.product, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}



extension AsynchronousRemoveTests {

    func test_RemovePersistable_SwiftTask() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of object.")

        db.write(barcode)
        XCTAssertEqual((db.readAll() as [Barcode]).count, 1, "There should be one barcodes in the database.")

        (db.asyncRemove(barcode) as Task<Void, Void, Void>).success { () -> Void in
            XCTAssertEqual((db.readAll() as [Barcode]).count, 0, "There should be no barcodes in the database.")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func test_RemovePersistables_SwiftTask() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async writing of object.")

        let _people = people()
        db.write(_people)
        XCTAssertEqual((db.readAll() as [Person]).count, _people.count, "There should be \(_people.count) Person in the database.")

        (db.asyncRemove(_people) as Task<Void, Void, Void>).success { () -> Void in
            XCTAssertEqual((db.readAll() as [Person]).count, 0, "There should be no Person in the database.")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

