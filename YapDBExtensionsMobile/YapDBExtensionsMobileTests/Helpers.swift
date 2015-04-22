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

func createYapDatabase(file: String, suffix: String? = .None) -> YapDatabase {

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

    let path = pathToDatabase(file.lastPathComponent, suffix: suffix?.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "()")))
    NSFileManager.defaultManager().removeItemAtPath(path, error: nil)

    return YapDatabase(path: path)
}

/// Value type with no metadata
func validateWrite<Value where Value: Saveable, Value: Persistable, Value: Equatable, Value.ArchiverType.ValueType == Value>(saved: Value, original: Value, usingDatabase db: YapDatabase) {
    XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

    if let read: Value = db.readAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
    }
    else { XCTFail("Value was not saved correctly to the database.") }
}

/// Value type with Object metadata
func validateWrite<ValueWithObjectMetadata where ValueWithObjectMetadata: Saveable, ValueWithObjectMetadata: ObjectMetadataPersistable, ValueWithObjectMetadata: Equatable, ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(saved: ValueWithObjectMetadata, original: ValueWithObjectMetadata, usingDatabase db: YapDatabase) {
    XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

    if let read: ValueWithObjectMetadata = db.readAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
    }
    else { XCTFail("Value was not saved correctly to the database.") }
}

/// Value type with Value metadata
func validateWrite<ValueWithValueMetadata where ValueWithValueMetadata: Saveable, ValueWithValueMetadata: ValueMetadataPersistable, ValueWithValueMetadata: Equatable, ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata>(saved: ValueWithValueMetadata, original: ValueWithValueMetadata, usingDatabase db: YapDatabase) {
    XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

    if let read: ValueWithValueMetadata = db.readAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
    }
    else { XCTFail("Value was not saved correctly to the database.") }
}

/// Object type with no metadata
func validateWrite<Object where Object: Persistable, Object: Equatable>(saved: Object, original: Object, usingDatabase db: YapDatabase) {
    XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

    if let read: Object = db.readAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
    }
    else { XCTFail("Value was not saved correctly to the database.") }
}

/// Object type with Object metadata
func validateWrite<ObjectWithObjectMetadata where ObjectWithObjectMetadata: ObjectMetadataPersistable, ObjectWithObjectMetadata: Equatable>(saved: ObjectWithObjectMetadata, original: ObjectWithObjectMetadata, usingDatabase db: YapDatabase) {
    XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

    if let read: ObjectWithObjectMetadata = db.readAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
    }
    else { XCTFail("Value was not saved correctly to the database.") }
}

/// Object type with Value metadata
func validateWrite<ObjectWithValueMetadata where ObjectWithValueMetadata: ValueMetadataPersistable, ObjectWithValueMetadata: Equatable>(saved: ObjectWithValueMetadata, original: ObjectWithValueMetadata, usingDatabase db: YapDatabase) {
    XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

    if let read: ObjectWithValueMetadata = db.readAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
    }
    else { XCTFail("Value was not saved correctly to the database.") }
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
