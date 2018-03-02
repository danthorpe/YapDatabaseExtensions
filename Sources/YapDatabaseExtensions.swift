//
//  Created by Daniel Thorpe on 08/04/2015.
//

import ValueCoding
import YapDatabase

/**

This is a struct used as a namespace for new types to
avoid any possible future clashes with `YapDatabase` types.

*/
public struct YapDB {

    /**
    Helper function for building the path to a database for easy use in the YapDatabase constructor.
    
    - parameter directory: a NSSearchPathDirectory value, use .DocumentDirectory for production.
    - parameter name: a String, the name of the sqlite file.
    - parameter suffix: a String, will be appended to the name of the file.
    
    - returns: a String representing the path to a database in the given search directory, with the given name/suffix.
    */
    public static func pathToDatabase(_ directory: FileManager.SearchPathDirectory, name: String, suffix: String? = .none) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)
        let directory: String = paths.first ?? NSTemporaryDirectory()
        let filename: String = {
            if let suffix = suffix {
                return "\(name)-\(suffix).sqlite"
            }
            return "\(name).sqlite"
        }()

        return (directory as NSString).appendingPathComponent(filename)
    }

    /// Type of closure which can perform operations on newly created/opened database instances.
    public typealias DatabaseOperationsBlock = (YapDatabase) -> Void

    /**
    Conveniently create or read a YapDatabase with the given name in the application's documents directory.
    
    Optionally, pass a block which receives the database instance, which is called
    before being returned. This block allows for things like registering extensions.
    
    Typical usage in a production environment would be to use this inside a singleton pattern, eg
    
        extension YapDB {
            public static var userDefaults: YapDatabase {
                get {
                    struct DatabaseSingleton {
                        static func database() -> YapDatabase {
                            return YapDB.databaseNamed("User Defaults")
                        }
                        static let instance = DatabaseSingleton.database()
                    }
                    return DatabaseSingleton.instance
                }
            }
        }

    which would allow the following behavior in your app:
    
        let userDefaultDatabase = YapDB.userDefaults
    
    Note that you can only use this convenience if you use the default serializers
    and sanitizers etc.

    - parameter name: a String, which will be the name of the SQLite database in the documents folder.
    - parameter operations: a DatabaseOperationsBlock closure, which receives the database,
    but is executed before the database is returned.
    
    - returns: the YapDatabase instance.
    */
    public static func databaseNamed(_ name: String, operations: DatabaseOperationsBlock? = .none) -> YapDatabase {
        let db =  YapDatabase(path: pathToDatabase(.documentDirectory, name: name, suffix: .none))
        operations?(db)
        return db
    }

    /**
    Conveniently create an empty database for testing purposes in the app's Caches directory.
    
    This function should only be used in unit tests, as it will delete any previously existing 
    SQLite file with the same path.
    
    It should only be used like this inside your test case.
    
        func test_MyUnitTest() {
            let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__)
            // etc etc
        }
    
        func test_GivenInitialData_MyUnitTest(initialDataImport: YapDB.DatabaseOperationsBlock) {
            let db = YapDB.testDatabaseForFile(__FILE__, test: __FUNCTION__, operations: initialDataImport)
            // etc etc
        }
    
    - parameter file: a String, which should be the swift special macro __FILE__
    - parameter test: a String, which should be the swift special macro __FUNCTION__
    - parameter operations: a DatabaseOperationsBlock closure, which receives the database,
    but is executed before the database is returned. This is very useful if you want to 
    populate the database with some objects before running the test.
    
    - returns: the YapDatabase instance.
    */
    public static func testDatabase(_ file: String = #file, test: String = #function, operations: DatabaseOperationsBlock? = .none) -> YapDatabase {
        let path = pathToDatabase(.cachesDirectory, name: (file as NSString).lastPathComponent, suffix: test.trimmingCharacters(in: CharacterSet(charactersIn: "()")))
        assert(!path.isEmpty, "Path should not be empty.")
        do {
            try FileManager.default.removeItem(atPath: path)
        }
        catch { }

        let db =  YapDatabase(path: path)
        operations?(db)
        return db
    }
}

extension YapDB {

    /**
    A database index value type.
    */
    public struct Index {

        /// The index's collection
        public let collection: String

        // The index's key
        public let key: String

        /**
        Create a new Index value.

        - parameter collection: a String
        - parameter key: a String
        */
        public init(collection: String, key: String) {
            self.collection = collection
            self.key = key
        }
    }
}

/**
A pairing (effectively a tuple) of a value and a metadata.
Used when values and metadatas are read or written together.
*/
public struct YapItem<Value, Metadata> {

    /// The item's value
    public let value: Value

    /// The item's metadata
    public let metadata: Metadata?

    /**
    Create a new YapItem value.

    - parameter value: the value associated with a `YapDB.Index`
    - parameter metadata: an optional metadata associated with a `YapDB.Index`
    */
    public init(_ value: Value, _ metadata: Metadata?) {
        self.value = value
        self.metadata = metadata
    }
}

// MARK: - Identifiable

/**
A generic protocol which is used to return a unique identifier
for the type. To use `String` type identifiers, use the aliased
Identifier type.
*/
public protocol Identifiable {
    associatedtype IdentifierType: CustomStringConvertible
    var identifier: IdentifierType { get }
}

/**
A typealias of String, which implements the Printable
protocol. When implementing the Identifiable protocol, use
Identifier for your String identifiers.

    extension Person: Identifiable {
      let identifier: Identifier
    }

*/
public typealias Identifier = String

// MARK: - Persistable

/**
Types which implement Persistable can be used in the functions
defined in this framework. It assumes that all instances of a type
are stored in the same YapDatabase collection.
*/
public protocol Persistable: Identifiable {

    /// The YapDatabase collection name the type is stored in.
    static var collection: String { get }
}

extension Persistable {

    /**
    Convenience static function to get an index for a given key 
    with this type's collection.
    
    - parameter key: a `String`
    - returns: a `YapDB.Index` value.
    */
    public static func indexWithKey(_ key: String) -> YapDB.Index {
        return YapDB.Index(collection: collection, key: key)
    }

    /**
    Convenience static function to get an array of indexes for an
    array of keys with this type's collection.
    
    - warning: This function will remove any duplicated keys and
    the order of the indexes is not guaranteed to match the keys.

    - parameter keys: a sequence of `String`s
    - returns: an array of `YapDB.Index` values.
    */
    public static func indexesWithKeys<
        Keys>(_ keys: Keys) -> [YapDB.Index] where
        Keys: Sequence,
        Keys.Iterator.Element == String {
            return keys.map { YapDB.Index(collection: collection, key: $0) }
    }

    /**
    Convenience computed property to get the key
    for a persistable, which is just the identifier's description.

    - returns: a String.
    */
    public var key: String {
        return identifier.description
    }

    /**
    Convenience computed property to get the index for a persistable.

    - returns: a `YapDB.Index`.
    */
    public var index: YapDB.Index {
        return type(of: self).indexWithKey(key)
    }
}

// MARK: Functions

public func keyForPersistable<P: Persistable>(_ persistable: P) -> String {
    return persistable.key
}

public func indexForPersistable<P: Persistable>(_ persistable: P) -> YapDB.Index {
    return persistable.index
}

// MARK: -

/// A facade interface for a read transaction.
public protocol ReadTransactionType {

    /**
    Returns all the keys of a collection.
    
    - parameter collection: a String. Not optional.
    - returns: an array of String values.
    */
    func keysInCollection(_ collection: String) -> [String]

    /**
    Read the object at the index.

    - parameter index: a YapDB.Index.
    - returns: an `AnyObject` if an item existing in the database for this index.
    */
    func readAtIndex(_ index: YapDB.Index) -> AnyObject?

    /**
    Read the metadata at the index.

    - parameter index: a YapDB.Index.
    - returns: an `AnyObject` if a metadata item existing in the database for this index.
    */
    func readMetadataAtIndex(_ index: YapDB.Index) -> AnyObject?
}

/// A facade interface for a write transaction.
public protocol WriteTransactionType: ReadTransactionType {

    /**
    Write the object to the database at the index, including optional metadata.
    
    - parameter index: the `YapDB.Index` to write to.
    - parameter object: the `AnyObject` which will be written.
    - parameter metadata: an optional `AnyObject` which will be written as metadata.
    */
    func writeAtIndex(_ index: YapDB.Index, object: AnyObject, metadata: AnyObject?)

    /**
    Remove the sequence object from the database at the indexes (if it exists), including metadata
    
    - parameter indexes: the `[YapDB.Index]` to remove.
    */
    func removeAtIndexes<
        Indexes>(_ indexes: Indexes) where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index
}

/// A facade interface for a database connection.
public protocol ConnectionType {
    associatedtype ReadTransaction: ReadTransactionType
    associatedtype WriteTransaction: WriteTransactionType

    /**
    Synchronously reads from the database on the connection. The closure receives
    the read transaction, and the function returns the result of the closure. This
    makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    - parameter block: a closure which receives YapDatabaseReadTransaction and returns T
    - returns: An instance of T
    */
    func read<T>(_ block: @escaping (ReadTransaction) -> T) -> T

    /**
    Synchronously writes to the database on the connection. The closure receives
    the read write transaction, and the function returns the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    - parameter block: a closure which receives YapDatabaseReadWriteTransaction and returns T
    - returns: An instance of T
    */
    func write<T>(_ block: @escaping (WriteTransaction) -> T) -> T

    /**
    Asynchronously reads from the database on the connection. The closure receives
    the read transaction, and completion block receives the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.
     
    The completion block is run on the given `queue`.

    - parameter block: a closure which receives YapDatabaseReadTransaction and returns T
    - parameter queue: a dispatch_queue_t, defaults to main queue, can be ommitted in most cases.
    - parameter completion: a closure which receives T and returns Void.
    */
    func asyncRead<T>(_ block: @escaping (ReadTransaction) -> T, queue: DispatchQueue, completion: @escaping (T) -> Void)

    /**
    Asynchronously writes to the database on the connection. The closure receives
    the read write transaction, and completion block receives the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    The completion block is run on the given `queue`.

    - parameter block: a closure which receives YapDatabaseReadWriteTransaction and returns T
    - parameter queue: a dispatch_queue_t, defaults to main queue, can be ommitted in most cases.
    - parameter completion: a closure which receives T and returns Void.
    */
    func asyncWrite<T>(_ block: @escaping (WriteTransaction) -> T, queue: DispatchQueue, completion: ((T) -> Void)?)

    /**
    Execute a read/write block inside a `NSOperation`. The block argument receives a
    `YapDatabaseReadWriteTransaction`. This method is very handy for writing
    different item types to the database inside the same transaction. For example

        let operation = connection.writeBlockOperation { transaction in
            people.write.on(transaction)
            barcode.write.on(transaction)
        }
        queue.addOperation(operation)

    - parameter block: a closure of type (YapDatabaseReadWriteTransaction) -> Void
    - returns: an `NSOperation`.
    */
    func writeBlockOperation(_ block: @escaping (WriteTransaction) -> Void) -> Operation
}

/// A facade interface for a database.
public protocol DatabaseType {
    associatedtype Connection: ConnectionType
    func makeNewConnection() -> Connection
}

internal enum Handle<D: DatabaseType> {
    case transaction(D.Connection.ReadTransaction)
    case connection(D.Connection)
    case database(D)
}

// MARK: - YapDatabaseReadTransaction

extension YapDatabaseReadTransaction: ReadTransactionType {

    /**
    Returns all the keys in a collection from the database

    - parameter collection: a String.
    - returns: an array of String values.
    */
    public func keysInCollection(_ collection: String) -> [String] {
        return allKeys(inCollection: collection)
    }

    /**
    Reads the object sored at this index using the transaction.

    - parameter index: The YapDB.Index value.
    - returns: An optional AnyObject.
    */
    public func readAtIndex(_ index: YapDB.Index) -> AnyObject? {
        return object(forKey: index.key, inCollection: index.collection) as AnyObject?
    }

    /**
    Reads any metadata sored at this index using the transaction.

    - parameter index: The YapDB.Index value.
    - returns: An optional AnyObject.
    */
    public func readMetadataAtIndex(_ index: YapDB.Index) -> AnyObject? {
        return metadata(forKey: index.key, inCollection: index.collection) as AnyObject?
    }
}

// MARK: - YapDatabaseReadWriteTransaction

extension YapDatabaseReadWriteTransaction: WriteTransactionType {

    public func writeAtIndex(_ index: YapDB.Index, object: AnyObject, metadata: AnyObject? = .none) {
        if let metadata: AnyObject = metadata {
            setObject(object, forKey: index.key, inCollection: index.collection, withMetadata: metadata)
        }
        else {
            setObject(object, forKey: index.key, inCollection: index.collection)
        }
    }

    func removeAtIndex(_ index: YapDB.Index) {
        removeObject(forKey: index.key, inCollection: index.collection)
    }

    public func removeAtIndexes<
        Indexes>(_ indexes: Indexes) where
        Indexes: Sequence,
        Indexes.Iterator.Element == YapDB.Index {
            indexes.forEach(removeAtIndex)
    }
}

extension YapDatabaseConnection: ConnectionType {

    /**
    Synchronously reads from the database on the connection. The closure receives
    the read transaction, and the function returns the result of the closure. This
    makes it very suitable as a building block for more functional methods.
    
    The majority of the wrapped functions provided by these extensions use this as 
    their basis.

    - parameter block: a closure which receives YapDatabaseReadTransaction and returns T
    - returns: An instance of T
    */
    public func read<T>(_ block: @escaping (YapDatabaseReadTransaction) -> T) -> T {
        var result: T! = .none
        self.read { result = block($0) }
        return result
    }

    /**
    Synchronously writes to the database on the connection. The closure receives
    the read write transaction, and the function returns the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    - parameter block: a closure which receives YapDatabaseReadWriteTransaction and returns T
    - returns: An instance of T
    */
    public func write<T>(_ block: @escaping (YapDatabaseReadWriteTransaction) -> T) -> T {
        var result: T! = .none
        readWrite { result = block($0) }
        return result
    }

    /**
    Asynchronously reads from the database on the connection. The closure receives
    the read transaction, and completion block receives the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    The completion block is run on the given `queue`.

    - parameter block: a closure which receives YapDatabaseReadTransaction and returns T
    - parameter queue: a dispatch_queue_t, defaults to main queue, can be ommitted in most cases.
    - parameter completion: a closure which receives T and returns Void.
    */
    public func asyncRead<T>(_ block: @escaping (YapDatabaseReadTransaction) -> T, queue: DispatchQueue = DispatchQueue.main, completion: @escaping (T) -> Void) {
        var result: T! = .none
        self.asyncRead({ result = block($0) }, completionQueue: queue) { completion(result) }
    }

    /**
    Asynchronously writes to the database on the connection. The closure receives
    the read write transaction, and completion block receives the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.
    
    The completion block is run on the given `queue`.

    - parameter block: a closure which receives YapDatabaseReadWriteTransaction and returns T
    - parameter queue: a dispatch_queue_t, defaults to main queue, can be ommitted in most cases.
    - parameter completion: a closure which receives T and returns Void.
    */
    public func asyncWrite<T>(_ block: @escaping (YapDatabaseReadWriteTransaction) -> T, queue: DispatchQueue = DispatchQueue.main, completion: ((T) -> Void)?) {
        var result: T! = .none
        asyncReadWrite({ result = block($0) }, completionQueue: queue) { completion?(result) }
    }

    /**
    Execute a read/write block inside a `NSOperation`. The block argument receives a
    `YapDatabaseReadWriteTransaction`. This method is very handy for writing
    different item types to the database inside the same transaction. For example

        let operation = connection.writeBlockOperation { transaction in
            people.write.on(transaction)
            barcode.write.on(transaction)
        }
        queue.addOperation(operation)

    - parameter block: a closure of type (YapDatabaseReadWriteTransaction) -> Void
    - returns: an `NSOperation`.
    */
    public func writeBlockOperation(_ block: @escaping (YapDatabaseReadWriteTransaction) -> Void) -> Operation {
        return BlockOperation { self.readWrite(block) }
    }
}

extension YapDatabase: DatabaseType {

    public func makeNewConnection() -> YapDatabaseConnection {
        return newConnection()
    }
}

// MARK: - YapDB.Index

// MARK: Hashable & Equality

extension YapDB.Index: Hashable {

    public var hashValue: Int {
        return description.hashValue
    }
}

public func == (a: YapDB.Index, b: YapDB.Index) -> Bool {
    return (a.collection == b.collection) && (a.key == b.key)
}

// MARK: CustomStringConvertible

extension YapDB.Index: CustomStringConvertible {

    public var description: String {
        return "\(collection):\(key)"
    }
}

// MARK: ValueCoding

extension YapDB.Index: ValueCoding {
    public typealias Coder = YapDBIndexCoder
}

// MARK: Coders

public final class YapDBIndexCoder: NSObject, NSCoding, CodingProtocol {
    public let value: YapDB.Index

    public init(_ v: YapDB.Index) {
        value = v
    }

    public required init(coder aDecoder: NSCoder) {
        let collection = aDecoder.decodeObject(forKey: "collection") as! String
        let key = aDecoder.decodeObject(forKey: "key") as! String
        value = YapDB.Index(collection: collection, key: key)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(value.collection, forKey: "collection")
        aCoder.encode(value.key, forKey: "key")
    }
}

// MARK: - Deprecations

@available(*, unavailable, renamed: "Persistable")
public typealias MetadataPersistable = Persistable

@available(*, unavailable, renamed: "Persistable")
public typealias ObjectMetadataPersistable = Persistable

@available(*, unavailable, renamed: "Persistable")
public typealias ValueMetadataPersistable = Persistable

@available(*, unavailable, renamed: "ValueCoding")
public typealias Saveable = ValueCoding

@available(*, unavailable, renamed: "CodingProtocol")
public typealias CodingType = CodingProtocol

@available(*, unavailable, renamed: "CodingProtocol")
public typealias Archiver = CodingProtocol
