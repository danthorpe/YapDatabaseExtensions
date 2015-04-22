//
//  PromiseKitTests.swift
//  YapDBExtensionsMobile
//
//  Created by Daniel Thorpe on 15/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import PromiseKit
import YapDatabase
import YapDatabaseExtensions
import YapDBExtensionsMobile

extension YapDatabaseValueTests {

    func testSavingValueAsynchronouslyWithPromises() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async promise saving.")

        (db.asyncSaveValue(barcode) as PromiseKit.Promise<Barcode>)
            .then { saved -> Void in
                validateSavedValue(saved, self.barcode, usingDatabase: db)
                expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

extension YapDatabaseValueWithMetadataTests {

    func testSavingValueAsynchronouslyWithPromises() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async promise saving.")

        (db.asyncSaveValue(product) as Promise<Product>)
            .then { saved -> Void in
                validateSavedValue(saved, self.product, usingDatabase: db)
                expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

extension YapDatabaseReplaceValueWithMetadataTests {

    func testReplaceingValueAsynchronouslyWithPromise() {
        let db = createYapDatabase(__FILE__, suffix: __FUNCTION__)
        db.saveValue(a)

        let expectation = expectationWithDescription("Finished async replacing using promises.")

        (db.asyncReplaceValue(b) as Promise<Product>)
            .then { replaced -> Void in
                validateSavedValue(replaced, self.b, usingDatabase: db)
                expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

