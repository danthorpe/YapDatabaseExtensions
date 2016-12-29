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
    var didKeysInCollection: String? = .none

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
    }

    var metadata: AnyObject? {
        get { return metadatas[0] }
        set { metadatas = [newValue] }
    }

    var didReadMetadataAtIndex: YapDB.Index? {
        get { return didReadMetadataAtIndexes.first }
    }

    var currentReadIndex = 0
    var objects: [AnyObject] = []
    var currentMetadataReadIndex = 0
    var metadatas: [AnyObject?] = []
    var didReadAtIndexes: [YapDB.Index] = []
    var didReadMetadataAtIndexes: [YapDB.Index] = []


    func getNextObject() -> AnyObject? {
        if objects.endIndex > currentReadIndex {
            let object = objects[currentReadIndex]
            currentReadIndex += 1
            return object
        }
        return .none
    }

    func getNextMetadata() -> AnyObject? {
        if metadatas.endIndex > currentMetadataReadIndex {
            let object = metadatas[currentMetadataReadIndex]
            currentMetadataReadIndex += 1
            return object
        }
        return .none
    }
}

extension TestableReadTransaction: ReadTransactionType {

    func keysInCollection(_ collection: String) -> [String] {
        didKeysInCollection = collection
        return keys
    }

    func readAtIndex(_ index: YapDB.Index) -> AnyObject? {
        didReadAtIndexes.append(index)
        return getNextObject()
    }

    func readMetadataAtIndex(_ index: YapDB.Index) -> AnyObject? {
        didReadMetadataAtIndexes.append(index)
        return getNextMetadata()
    }
}

class TestableWriteTransaction: TestableReadTransaction {
    typealias Payload = (YapDB.Index, AnyObject, AnyObject?)

    var didWriteAtIndexes: [Payload] = []
    var didRemoveAtIndexes: [YapDB.Index] = []
}

extension TestableWriteTransaction: WriteTransactionType {

    func writeAtIndex(_ index: YapDB.Index, object: AnyObject, metadata: AnyObject?) {
        didWriteAtIndexes.append((index, object, metadata))
    }

    func removeAtIndexes<
        Indexes>(_ indexes: Indexes) where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index {
            didRemoveAtIndexes = Array(indexes)
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

    func read<T>(_ block: @escaping (TestableReadTransaction) -> T) -> T {
        didRead = true
        return block(readTransaction)
    }

    func write<T>(_ block: @escaping (TestableWriteTransaction) -> T) -> T {
        didWrite = true
        return block(writeTransaction)
    }

    func asyncRead<T>(_ block: @escaping (TestableReadTransaction) -> T, queue: DispatchQueue, completion: @escaping (T) -> Void) {
        didAsyncRead = true
        queue.async { [transaction = self.readTransaction] in
            completion(block(transaction))
        }
    }

    func asyncWrite<T>(_ block: @escaping (TestableWriteTransaction) -> T, queue: DispatchQueue, completion: ((T) -> Void)? = .none) {
        didAsyncWrite = true
        queue.async { [transaction = self.writeTransaction] in
            let result = block(transaction)
            completion?(result)
        }
    }

    func writeBlockOperation(_ block: @escaping (TestableWriteTransaction) -> Void) -> Operation {
        didWriteBlockOperation = true
        return BlockOperation { block(self.writeTransaction) }
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




