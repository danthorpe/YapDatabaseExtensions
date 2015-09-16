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

/// Value type with no metadata
func validateWrite<
    Value
    where
    Value: Saveable,
    Value: Persistable,
    Value: Equatable,
    Value.ArchiverType: NSCoding,
    Value.ArchiverType.ValueType == Value>(saved: Value, original: Value, usingDatabase db: YapDatabase) {
    XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

    if let read: Value = db.readAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
    }
    else { XCTFail("Value was not saved correctly to the database.") }
}

/// Value type with Object metadata
func validateWrite<
    ValueWithObjectMetadata
    where
    ValueWithObjectMetadata: Saveable,
    ValueWithObjectMetadata: ObjectMetadataPersistable,
    ValueWithObjectMetadata: Equatable,
    ValueWithObjectMetadata.MetadataType: Equatable,
    ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(saved: ValueWithObjectMetadata, original: ValueWithObjectMetadata, usingDatabase db: YapDatabase) {
    XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

    if let read: ValueWithObjectMetadata = db.readAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
    }
    else {
        XCTFail("Value was not saved correctly to the database.")
    }

    if let meta: ValueWithObjectMetadata.MetadataType = db.readMetadataAtIndex(indexForPersistable(original)) {
        XCTAssertEqual(meta, original.metadata, "The value returned from a save value function should equal the argument.")
    }
    else {
        XCTFail("Value was not saved correctly to the database.")
    }
}

/// Value type with Value metadata
func validateWrite<
    ValueWithValueMetadata
    where
    ValueWithValueMetadata: Saveable,
    ValueWithValueMetadata: ValueMetadataPersistable,
    ValueWithValueMetadata: Equatable,
    ValueWithValueMetadata.ArchiverType: NSCoding,
    ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata,
    ValueWithValueMetadata.MetadataType: Equatable,
    ValueWithValueMetadata.MetadataType.ArchiverType: NSCoding,
    ValueWithValueMetadata.MetadataType.ArchiverType.ValueType == ValueWithValueMetadata.MetadataType>(saved: ValueWithValueMetadata, original: ValueWithValueMetadata, usingDatabase db: YapDatabase) {


        XCTAssertEqual(saved, original, "The value returned from a save value function should equal the argument.")

        if let read: ValueWithValueMetadata = db.readAtIndex(indexForPersistable(original)) {
            XCTAssertEqual(read, original, "The value returned from a save value function should equal the argument.")
        }
        else {
            XCTFail("Value was not saved correctly to the database.")
        }

        if let meta: ValueWithValueMetadata.MetadataType = db.readMetadataAtIndex(indexForPersistable(original)) {
            XCTAssertEqual(meta, original.metadata, "The value returned from a save value function should equal the argument.")
        }
        else {
            XCTFail("Value was not saved correctly to the database.")
        }
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


