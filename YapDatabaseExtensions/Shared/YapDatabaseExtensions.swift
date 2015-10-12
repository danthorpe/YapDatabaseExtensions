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
    Helper function for evaluating the path to a database for easy use in the YapDatabase constructor.
    
    - parameter directory: a NSSearchPathDirectory value, use .DocumentDirectory for production.
    - parameter name: a String, the name of the sqlite file.
    - parameter suffix: a String, will be appended to the name of the file.
    
    - returns: a String
    */
    public static func pathToDatabase(directory: NSSearchPathDirectory, name: String, suffix: String? = .None) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(directory, .UserDomainMask, true)
        let directory: String = paths.first ?? NSTemporaryDirectory()
        let filename: String = {
            if let suffix = suffix {
                return "\(name)-\(suffix).sqlite"
            }
            return "\(name).sqlite"
        }()

        return (directory as NSString).stringByAppendingPathComponent(filename)
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
    public static func databaseNamed(name: String, operations: DatabaseOperationsBlock? = .None) -> YapDatabase {
        let db =  YapDatabase(path: pathToDatabase(.DocumentDirectory, name: name, suffix: .None))
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
    public static func testDatabase(file: String = __FILE__, test: String = __FUNCTION__, operations: DatabaseOperationsBlock? = .None) -> YapDatabase {
        let path = pathToDatabase(.CachesDirectory, name: (file as NSString).lastPathComponent, suffix: test.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "()")))
        assert(!path.isEmpty, "Path should not be empty.")
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
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

// MARK: - Identifiable

/**
A generic protocol which is used to return a unique identifier
for the type. To use `String` type identifiers, use the aliased
Identifier type.
*/
public protocol Identifiable {
    typealias IdentifierType: CustomStringConvertible
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

extension Identifier: CustomStringConvertible {
    public var description: String { return self }
}

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
    public static func indexWithKey(key: String) -> YapDB.Index {
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
    public static func indexesWithKeys<Keys: SequenceType where Keys.Generator.Element == String>(keys: Keys) -> [YapDB.Index] {
        return Set(keys).map { YapDB.Index(collection: collection, key: $0) }
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
        return self.dynamicType.indexWithKey(key)
    }
}

/**
A generic protocol for Persistable which support YapDatabase metadata.

In order to read/write your metadata types from/to YapDatabase they must
implement either NSCoding (i.e. be object based) or Saveable (i.e. be 
value based).
*/
public protocol MetadataPersistable: Persistable {
    typealias MetadataType

    /// A metadata which is set when reading, and get when writing.
    var metadata: MetadataType? { get set }
}

/// A facade interface for a read transaction.
public protocol ReadTransactionType {

    /**
    Returns all the keys of a collection.
    
    - parameter collection: a String. Not optional.
    - returns: an array of String values.
    */
    func keysInCollection(collection: String) -> [String]

    /**
    Read the object at the index.

    - parameter index: a YapDB.Index.
    - returns: an `AnyObject` if an item existing in the database for this index.
    */
    func readAtIndex(index: YapDB.Index) -> AnyObject?

    /**
    Read the metadata at the index.

    - parameter index: a YapDB.Index.
    - returns: an `AnyObject` if a metadata item existing in the database for this index.
    */
    func readMetadataAtIndex(index: YapDB.Index) -> AnyObject?
}

/// A facade interface for a write transaction.
public protocol WriteTransactionType: ReadTransactionType {

    /**
    Write the object to the database at the index, including optional metadata.
    
    - parameter index: the `YapDB.Index` to write to.
    - parameter object: the `AnyObject` which will be written.
    - parameter metadata: an optional `AnyObject` which will be written as metadata.
    */
    func writeAtIndex(index: YapDB.Index, object: AnyObject, metadata: AnyObject?)

    /**
    Remove the sequence object from the database at the indexes (if it exists), including metadata
    
    - parameter indexes: the `[YapDB.Index]` to remove.
    */
    func removeAtIndexes(indexes: [YapDB.Index])
}

/// A facade interface for a database connection.
public protocol ConnectionType {
    typealias ReadTransaction: ReadTransactionType
    typealias WriteTransaction: WriteTransactionType

    /**
    Synchronously reads from the database on the connection. The closure receives
    the read transaction, and the function returns the result of the closure. This
    makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    - parameter block: a closure which receives YapDatabaseReadTransaction and returns T
    - returns: An instance of T
    */
    func read<T>(block: ReadTransaction -> T) -> T

    /**
    Synchronously writes to the database on the connection. The closure receives
    the read write transaction, and the function returns the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    - parameter block: a closure which receives YapDatabaseReadWriteTransaction and returns T
    - returns: An instance of T
    */
    func write<T>(block: WriteTransaction -> T) -> T

    /**
    Asynchronously reads from the database on the connection. The closure receives
    the read transaction, and completion block receives the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    - parameter block: a closure which receives YapDatabaseReadTransaction and returns T
    - parameter queue: a dispatch_queue_t, defaults to main queue, can be ommitted in most cases.
    - parameter completion: a closure which receives T and returns Void.
    */
    func asyncRead<T>(block: ReadTransaction -> T, queue: dispatch_queue_t, completion: (T) -> Void)

    /**
    Asynchronously writes to the database on the connection. The closure receives
    the read write transaction, and completion block receives the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    - parameter block: a closure which receives YapDatabaseReadWriteTransaction and returns T
    - parameter queue: a dispatch_queue_t, defaults to main queue, can be ommitted in most cases.
    - parameter completion: a closure which receives T and returns Void.
    */
    func asyncWrite<T>(block: WriteTransaction -> T, queue: dispatch_queue_t, completion: (T) -> Void)

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
    func writeBlockOperation(block: WriteTransaction -> Void) -> NSOperation
}

/// A facade interface for a database.
public protocol DatabaseType {
    typealias Connection: ConnectionType
    func makeNewConnection() -> Connection
}

internal enum Handle<D: DatabaseType> {
    case Transaction(D.Connection.ReadTransaction)
    case Connection(D.Connection)
    case Database(D)
}

// MARK: - YapDatabaseReadTransaction

extension YapDatabaseReadTransaction: ReadTransactionType {

    /**
    Returns all the keys in a collection from the database

    - parameter collection: a String.
    - returns: an array of String values.
    */
    public func keysInCollection(collection: String) -> [String] {
        return allKeysInCollection(collection) as! [String]
    }

    /**
    Reads the object sored at this index using the transaction.

    - parameter index: The YapDB.Index value.
    - returns: An optional AnyObject.
    */
    public func readAtIndex(index: YapDB.Index) -> AnyObject? {
        return objectForKey(index.key, inCollection: index.collection)
    }

    /**
    Reads any metadata sored at this index using the transaction.

    - parameter index: The YapDB.Index value.
    - returns: An optional AnyObject.
    */
    public func readMetadataAtIndex(index: YapDB.Index) -> AnyObject? {
        return metadataForKey(index.key, inCollection: index.collection)
    }
}

// MARK: - YapDatabaseReadWriteTransaction

extension YapDatabaseReadWriteTransaction: WriteTransactionType {

    public func writeAtIndex(index: YapDB.Index, object: AnyObject, metadata: AnyObject? = .None) {
        if let metadata: AnyObject = metadata {
            setObject(object, forKey: index.key, inCollection: index.collection, withMetadata: metadata)
        }
        else {
            setObject(object, forKey: index.key, inCollection: index.collection)
        }
    }

    func removeAtIndex(index: YapDB.Index) {
        removeObjectForKey(index.key, inCollection: index.collection)
    }

    public func removeAtIndexes(indexes: [YapDB.Index]) {
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
    public func read<T>(block: YapDatabaseReadTransaction -> T) -> T {
        var result: T! = .None
        readWithBlock { result = block($0) }
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
    public func write<T>(block: YapDatabaseReadWriteTransaction -> T) -> T {
        var result: T! = .None
        readWriteWithBlock { result = block($0) }
        return result
    }

    /**
    Asynchronously reads from the database on the connection. The closure receives
    the read transaction, and completion block receives the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    - parameter block: a closure which receives YapDatabaseReadTransaction and returns T
    - parameter queue: a dispatch_queue_t, defaults to main queue, can be ommitted in most cases.
    - parameter completion: a closure which receives T and returns Void.
    */
    public func asyncRead<T>(block: YapDatabaseReadTransaction -> T, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (T) -> Void) {
        var result: T! = .None
        asyncReadWithBlock({ result = block($0) }, completionQueue: queue) { completion(result) }
    }

    /**
    Asynchronously writes to the database on the connection. The closure receives
    the read write transaction, and completion block receives the result of the closure.
    This makes it very suitable as a building block for more functional methods.

    The majority of the wrapped functions provided by these extensions use this as
    their basis.

    - parameter block: a closure which receives YapDatabaseReadWriteTransaction and returns T
    - parameter queue: a dispatch_queue_t, defaults to main queue, can be ommitted in most cases.
    - parameter completion: a closure which receives T and returns Void.
    */
    public func asyncWrite<T>(block: YapDatabaseReadWriteTransaction -> T, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (T) -> Void) {
        var result: T! = .None
        asyncReadWriteWithBlock({ result = block($0) }, completionQueue: queue) { completion(result) }
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
    public func writeBlockOperation(block: (YapDatabaseReadWriteTransaction) -> Void) -> NSOperation {
        return NSBlockOperation { self.readWriteWithBlock(block) }
    }
}

extension YapDatabase: DatabaseType {

    public func makeNewConnection() -> YapDatabaseConnection {
        return newConnection()
    }
}


// MARK: Hashable etc

extension YapDB.Index: CustomStringConvertible, Hashable {

    public var description: String {
        return "\(collection):\(key)"
    }

    public var hashValue: Int {
        return description.hashValue
    }
}

public func == (a: YapDB.Index, b: YapDB.Index) -> Bool {
    return (a.collection == b.collection) && (a.key == b.key)
}

// MARK: Saveable

extension YapDB.Index: ValueCoding {
    public typealias Coder = YapDBIndexCoder
}

// MARK: Archivers

public final class YapDBIndexCoder: NSObject, NSCoding, CodingType {
    public let value: YapDB.Index

    public init(_ v: YapDB.Index) {
        value = v
    }

    public required init(coder aDecoder: NSCoder) {
        let collection = aDecoder.decodeObjectForKey("collection") as! String
        let key = aDecoder.decodeObjectForKey("key") as! String
        value = YapDB.Index(collection: collection, key: key)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.collection, forKey: "collection")
        aCoder.encodeObject(value.key, forKey: "key")
    }
}





// MARK: - Functions

public func keyForPersistable<P: Persistable>(persistable: P) -> String {
    return persistable.key
}

public func indexForPersistable<P: Persistable>(persistable: P) -> YapDB.Index {
    return persistable.index
}

// MARK: - Deprecations

@available(*, unavailable, renamed="MetadataPersistable")
public typealias ObjectMetadataPersistable = MetadataPersistable

@available(*, unavailable, renamed="MetadataPersistable")
public typealias ValueMetadataPersistable = MetadataPersistable

@available(*, unavailable, renamed="ValueCoding")
public typealias Saveable = ValueCoding

@available(*, unavailable, renamed="CodingType")
public typealias Archiver = CodingType



