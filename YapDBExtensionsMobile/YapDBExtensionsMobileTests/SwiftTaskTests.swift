//
//  SwiftTaskTests.swift
//  YapDBExtensionsMobile
//
//  Created by Daniel Thorpe on 15/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import SwiftTask
import YapDatabase
import YapDatabaseExtensions
import YapDBExtensionsMobile

extension YapDatabaseValueTests {

    func testSavingValueAsynchronouslyWithSwiftTask() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async swift tasks saving.")

        (db.asyncSaveValue(barcode) as Task<Void, Barcode, Void>).success { saved -> Void in
            validateSavedValue(saved, self.barcode, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

extension YapDatabaseValueWithMetadataTests {

    func testSavingValueAsynchronouslyWithSwiftTask() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async swift task saving.")

        (db.asyncSaveValue(product) as Task<Void, Product, Void>).success { saved -> Void in
            validateSavedValue(saved, self.product, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

extension YapDatabaseReplaceValueWithMetadataTests {

    func testReplaceingValueAsynchronouslyWithSwiftTask() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        db.saveValue(a)

        let expectation = expectationWithDescription("Finished async swift tasks replace.")

        (db.asyncReplaceValue(b) as Task<Void, Product, Void>).success { replacement -> Void in
            validateSavedValue(replacement, self.b, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

