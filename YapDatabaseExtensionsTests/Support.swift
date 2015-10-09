//
//  Support.swift
//  YapDatabaseExtensions
//
//  Created by Daniel Thorpe on 09/10/2015.
//  Copyright © 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
@testable import YapDatabaseExtensions

class TestableReadTransaction {

    var keys: [String] = []
    var didKeysInCollection: String? = .None

    var object: AnyObject? {
        get { return objects.first }
        set {
            if let newObject = newValue {
                objects = [newObject]
            }
            else {
                objects = []
            }
        }
    }

    var didReadAtIndex: YapDB.Index? {
        get { return didReadAtIndexes.first }
        set {
            if let newIndex = newValue {
                didReadAtIndexes = [newIndex]
            }
            else {
                didReadAtIndexes = []
            }
        }
    }

    var metadata: AnyObject? {
        get { return metadatas.first }
        set {
            if let newObject = newValue {
                metadatas = [newObject]
            }
            else {
                metadatas = []
            }
        }
    }

    var didReadMetadataAtIndex: YapDB.Index? {
        get { return didReadMetadataAtIndexes.first }
        set {
            if let newIndex = newValue {
                didReadMetadataAtIndexes = [newIndex]
            }
            else {
                didReadMetadataAtIndexes = []
            }
        }
    }

    var currentReadIndex = 0
    var objects: [AnyObject] = []
    var metadatas: [AnyObject] = []
    var didReadAtIndexes: [YapDB.Index] = []
    var didReadMetadataAtIndexes: [YapDB.Index] = []


    func getNextObject() -> AnyObject? {
        if objects.endIndex > currentReadIndex {
            let object = objects[currentReadIndex]
            currentReadIndex += 1
            return object
        }
        return .None
    }

    func getNextMetadata() -> AnyObject? {
        if metadatas.endIndex > currentReadIndex {
            let object = metadatas[currentReadIndex]
            currentReadIndex += 1
            return object
        }
        return .None
    }
}

extension TestableReadTransaction: ReadTransactionType {

    func keysInCollection(collection: String) -> [String] {
        didKeysInCollection = collection
        return keys
    }

    func readAtIndex(index: YapDB.Index) -> AnyObject? {
        didReadAtIndexes.append(index)
        return getNextObject()
    }

    func readMetadataAtIndex(index: YapDB.Index) -> AnyObject? {
        didReadMetadataAtIndexes.append(index)
        return getNextMetadata()
    }
}

class TestableWriteTransaction: TestableReadTransaction {

    var didWriteAtIndex: (YapDB.Index, AnyObject, AnyObject?)? = .None
}

extension TestableWriteTransaction: WriteTransactionType {

    func writeAtIndex(index: YapDB.Index, object: AnyObject, metadata: AnyObject?) {
        didWriteAtIndex = (index, object, metadata)
    }
}

class TestableConnection {
    var readTransaction = TestableReadTransaction()
    var writeTransaction = TestableWriteTransaction()

    var didRead = false
    var didWrite = false
    var didAsyncRead = false
    var didAsyncWrite = false
    var didWriteBlockOperation = false
}

extension TestableConnection: ConnectionType {

    func read<T>(block: TestableReadTransaction -> T) -> T {
        didRead = true
        return block(readTransaction)
    }

    func write<T>(block: TestableWriteTransaction -> T) -> T {
        didWrite = true
        return block(writeTransaction)
    }

    func asyncRead<T>(block: TestableReadTransaction -> T, queue: dispatch_queue_t, completion: (T) -> Void) {
        didAsyncRead = true
        dispatch_async(queue) { [transaction = self.readTransaction] in
            completion(block(transaction))
        }
    }

    func asyncWrite<T>(block: TestableWriteTransaction -> T, queue: dispatch_queue_t, completion: (T) -> Void) {
        didAsyncWrite = true
        dispatch_async(queue) { [transaction = self.writeTransaction] in
            completion(block(transaction))
        }
    }

    func writeBlockOperation(block: TestableWriteTransaction -> Void) -> NSOperation {
        didWriteBlockOperation = true
        return NSBlockOperation { block(self.writeTransaction) }
    }
}

class TestableDatabase {

    var connection: TestableConnection!
    var didMakeNewConnection = false
}

extension TestableDatabase: DatabaseType {

    func makeNewConnection() -> TestableConnection {
        didMakeNewConnection = true
        return connection
    }
}




