//
//  Helpers.swift
//  YapDBExtensionsMobile
//
//  Created by Daniel Thorpe on 15/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import XCTest
import YapDatabase
import YapDatabaseExtensions

func createYapDatabase(suffix: String? = .None) -> YapDatabase {

    func pathToDatabase(name: String, suffix: String? = .None) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let directory: String = (paths.first as? String) ?? NSTemporaryDirectory()
        let filename: String = {
            if let suffix = suffix {
                return "\(name)-\(suffix).sqlite"
            }
            return "\(name).sqlite"
            }()
        return directory.stringByAppendingPathComponent(filename)
    }

    let path = pathToDatabase(__FILE__.lastPathComponent, suffix: suffix?.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "()")))
    NSFileManager.defaultManager().removeItemAtPath(path, error: nil)

    return YapDatabase(path: path)
}


func validateSavedValue<V where V: Saveable, V: Persistable, V: Equatable, V.ArchiverType.ValueType == V>(saved: V, original: V, usingDatabase db: YapDatabase) {
    XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

    if let read: V = db.readValueAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
    }
    else {
        XCTFail("Value was not saved correctly to the database.")
    }
}

func validateSavedValue<V where V: Saveable, V: ValueMetadataPersistable, V: Equatable, V.ArchiverType.ValueType == V>(saved: V, original: V, usingDatabase db: YapDatabase) {
    XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

    if let read: V = db.readValueAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
    }
    else {
        XCTFail("Value was not saved correctly to the database.")
    }
}
