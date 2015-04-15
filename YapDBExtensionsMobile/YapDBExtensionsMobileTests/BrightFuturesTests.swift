//
//  BrightFuturesTests.swift
//  YapDBExtensionsMobile
//
//  Created by Daniel Thorpe on 15/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import BrightFutures
import YapDatabase
import YapDatabaseExtensions
import YapDBExtensionsMobile

extension YapDatabaseValueTests {

    func testSavingValueAsynchronouslyWithBrightFutures() {
        let db = createYapDatabase(suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async bright futures saving.")

        (db.asyncSaveValue(barcode) as Future<Barcode>).onSuccess { saved in
            validateSavedValue(saved, self.barcode, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }    
}

extension YapDatabaseValueWithMetadataTests {

    func testSavingValueAsynchronouslyWithBrightFutures() {
        let db = createYapDatabase(suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async bright futures saving.")

        (db.asyncSaveValue(product) as Future<Product>).onSuccess { saved in
            validateSavedValue(saved, self.product, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

extension YapDatabaseReplaceValueWithMetadataTests {

    func testReplaceingValueAsynchronouslyWithBrightFutures() {
        let db = createYapDatabase(suffix: __FUNCTION__)
        db.saveValue(a)

        let expectation = expectationWithDescription("Finished async bright futures replace.")

        (db.asyncReplaceValue(b) as Future<Product>).onSuccess { replacement in
            validateSavedValue(replacement, self.b, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

