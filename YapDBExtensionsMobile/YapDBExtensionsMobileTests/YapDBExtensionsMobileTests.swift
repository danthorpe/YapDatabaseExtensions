//
//  YapDBExtensionsMobileTests.swift
//  YapDBExtensionsMobileTests
//
//  Created by Daniel Thorpe on 15/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import XCTest
import YapDatabase
import YapDatabaseExtensions
import YapDBExtensionsMobile

class YapDatabaseValueTests: XCTestCase {

    let barcode: Barcode = .QRCode("I have no idea what the string of a QR Code might look like")

    func testSavingAndReadingValueSynchonously() {
        let db = createYapDatabase(suffix: __FUNCTION__)
        validateSavedValue(db.saveValue(barcode), barcode, usingDatabase: db)
    }

    func testSavingValueAsynchronously() {
        let db = createYapDatabase(suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async saving.")

        db.asyncSaveValue(barcode) { saved in
            validateSavedValue(saved, self.barcode, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

class YapDatabaseValueWithMetadataTests: XCTestCase {

    let product = Product(metadata: Product.Metadata(categoryIdentifier: 1), identifier: "cocoa-123", name: "CocoaPops", barcode: .UPCA(1, 2, 3, 4))

    func testSavingAndReadingValueSynchonously() {
        let db = createYapDatabase(suffix: __FUNCTION__)
        validateSavedValue(db.saveValue(product), product, usingDatabase: db)
    }

    func testSavingValueAsynchronously() {
        let db = createYapDatabase(suffix: __FUNCTION__)
        let expectation = expectationWithDescription("Finished async saving.")

        db.asyncSaveValue(product) { saved in
            validateSavedValue(saved, self.product, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}

class YapDatabaseReplaceValueWithMetadataTests: XCTestCase {

    let a = Product(metadata: Product.Metadata(categoryIdentifier: 1), identifier: "cocoa-123", name: "CocoaPops", barcode: .UPCA(1, 2, 3, 4))
    let b = Product(metadata: Product.Metadata(categoryIdentifier: 2), identifier: "cocoa-123", name: "CocoaPops", barcode: .UPCA(1, 2, 5, 6))

    func testReplaceingValueSynchronously() {
        let db = createYapDatabase(suffix: __FUNCTION__)
        db.saveValue(a)
        validateSavedValue(db.replaceValue(b), b, usingDatabase: db)
    }

    func testReplaceingValueAsynchronously() {
        let db = createYapDatabase(suffix: __FUNCTION__)
        db.saveValue(a)

        let expectation = expectationWithDescription("Finished async replacing.")

        db.asyncReplaceValue(b) { replaced in
            validateSavedValue(replaced, self.b, usingDatabase: db)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

}



