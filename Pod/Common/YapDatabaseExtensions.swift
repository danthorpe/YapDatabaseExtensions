//
//  Created by Daniel Thorpe on 08/04/2015.
//

import YapDatabase

// MARK: Identifier

public typealias Identifier = String

extension Identifier: Printable {
    public var description: String { return self }
}

// MARK: - Archiver & Saveable

public protocol Archiver: NSCoding {
    typealias ValueType
    var value: ValueType { get }
    init(_: ValueType)
}

public protocol Saveable {
    typealias ArchiverType: Archiver
    var archive: ArchiverType { get }
}

public func valueFromArchive<Value where Value: Saveable, Value.ArchiverType.ValueType == Value>(archive: AnyObject?) -> Value? {
    return archive.map { ($0 as! Value.ArchiverType).value }
}

public func valuesFromArchives<Archives, Value where Archives: SequenceType, Archives.Generator.Element == AnyObject, Value: Saveable, Value.ArchiverType.ValueType == Value>(archives: Archives?) -> [Value]? {
    return archives.map { map($0, valueFromArchive) }
}

public func archiveFromValue<Value where Value: Saveable, Value.ArchiverType.ValueType == Value>(value: Value?) -> Value.ArchiverType? {
    return value.map { $0.archive }
}

public func archivesFromValues<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value.ArchiverType.ValueType == Value>(values: Values?) -> [Value.ArchiverType]? {
    return values.map { map($0, { archiveFromValue($0) }) }
}

// MARK: - Persistable

/**

This is an empty struct used as a namespace for new types to
avoid any possible future clashes with `YapDatabase` types.

*/
public struct YapDB { }

extension YapDB {

    /**

    A database index value type.
    
    :param: collection A String
    :param: key A String
    */
    public struct Index {
        public let collection: String
        public let key: String

        public init(collection: String, key: String) {
            self.collection = collection
            self.key = key
        }
    }
}

public protocol Identifiable {
    typealias IdentifierType: Printable
    var identifier: IdentifierType { get }
}

public protocol Persistable: Identifiable {
    static var collection: String { get }
}

public protocol ObjectMetadataPersistable: Persistable {
    typealias MetadataType: NSCoding
    var metadata: MetadataType { get }
}

public protocol ValueMetadataPersistable: Persistable {
    typealias MetadataType: Saveable
    var metadata: MetadataType { get }
}

public func indexForPersistable<P: Persistable>(persistable: P) -> YapDB.Index {
    return YapDB.Index(collection: persistable.dynamicType.collection, key: "\(persistable.identifier)")
}

internal func map<S: SequenceType, T>(source: S, transform: (S.Generator.Element) -> T?) -> [T] {
    return reduce(source, [T](), { (var accumulator, element) -> [T] in
        if let transformed = transform(element) {
            accumulator.append(transformed)
        }
        return accumulator
    })
}

extension YapDatabaseConnection {

    public func read<T>(block: (YapDatabaseReadTransaction) -> T) -> T {
        var result: T! = .None
        readWithBlock { transaction in
            result = block(transaction)
        }
        return result
    }

    public func write<T>(block: (YapDatabaseReadWriteTransaction) -> T) -> T {
        var result: T! = .None
        readWriteWithBlock { transaction in
            result = block(transaction)
        }
        return result
    }

    public func asyncRead<T>(block: (YapDatabaseReadTransaction) -> T, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (T) -> Void) {
        var result: T! = .None
        asyncReadWithBlock({ transaction in result = block(transaction) }, completionQueue: queue) { completion(result) }
    }
}


