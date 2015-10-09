//
//  Created by Daniel Thorpe on 22/04/2015.
//
//

import YapDatabase

// MARK: - YapDatabaseTransaction

extension YapDatabaseReadTransaction: ReadTransactionType {

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

// MARK: - Readable

public protocol Readable {
    typealias ItemType

    var transaction: ReadTransactionType? { get }
    var connection: ConnectionType { get }
}


public struct Read<Item>: Readable {
    public typealias ItemType = Item

    let reader: Handle

    public var transaction: ReadTransactionType? {
        if case let .Transaction(transaction) = reader {
            return transaction
        }
        return .None
    }

    public var connection: ConnectionType {
        switch reader {
        case .Transaction(_):
            fatalError("Attempting to get connection from a transaction.")
        case .Connection(let connection):
            return connection
        default:
            return database.newConnection()
        }
    }

    internal var database: YapDatabase {
        if case let .Database(database) = reader {
            return database
        }
        fatalError("Attempting to get database from \(reader)")
    }

    internal init(_ transaction: ReadTransactionType) {
        reader = .Transaction(transaction)
    }

    internal init(_ connection: ConnectionType) {
        reader = .Connection(connection)
    }

    internal init(_ database: YapDatabase) {
        reader = .Database(database)
    }
}

extension Persistable {

    /**
    Returns a type suitable for *reading* from the transaction. The available
    functions will depend on your own types correctly implementing Persistable,
    MetadataPersistable and Saveable.
    
    For example, given the key for a `Person` type, and you are in a read
    transaction block, the following would read the object for you.
    
        if let person = Person.read(transaction).key(key) {
            print("Hello \(person.name)")
        }
    
    Note that this API is consistent for Object types, Value types, with or
    without metadata.
    
    - parameter transaction: a type conforming to ReadTransactionType such as
    YapDatabaseReadTransaction
    */
    public static func read(transaction: ReadTransactionType) -> Read<Self> {
        return Read(transaction)
    }

    /**
    Returns a type suitable for Reading from a database connection. The available
    functions will depend on your own types correctly implementing Persistable,
    MetadataPersistable and Saveable.

    For example, given the key for a `Person` type, and you have a database 
    connection.

        if let person = Person.read(connection).key(key) {
            print("Hello \(person.name)")
        }

    Note that this API is consistent for Object types, Value types, with or
    without metadata.

    - parameter connection: a type conforming to ConnectionType such as
    YapDatabaseConnection.
    */
    public static func read(connection: ConnectionType) -> Read<Self> {
        return Read(connection)
    }

    internal static func read(database: YapDatabase) -> Read<Self> {
        return Read(database)
    }
}

extension Readable
    where
    ItemType: Persistable {

    func sync<T>(block: (ReadTransactionType) -> T) -> T {
        if let transaction = transaction {
            return block(transaction)
        }
        else {
            return connection.read(block)
        }
    }
}

// MARK: - Object with no metadata

extension Readable
    where
    ItemType: NSCoding,
    ItemType: Persistable {

    func inTransaction(transaction: ReadTransactionType, atIndex index: YapDB.Index) -> ItemType? {
        return transaction.readAtIndex(index) as? ItemType
    }

    func inTransactionAtIndex(transaction: ReadTransactionType) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> ReadTransactionType -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction)) ?? []
        }
    }

    func inTransaction(transaction: ReadTransactionType, atKey key: String) -> ItemType? {
        return transaction.readAtIndex(ItemType.indexWithKey(key)) as? ItemType
    }

    func inTransactionAtKey(transaction: ReadTransactionType) -> String -> ItemType? {
        return { self.inTransaction(transaction, atKey: $0) }
    }

    func atKeyInTransaction(key: String) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atKey: key) }
    }

    func atKeysInTransaction(_keys: [String]? = .None) -> ReadTransactionType -> [ItemType] {
        let atKey = inTransactionAtKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(atKey(transaction)) ?? []
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(atKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(atKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(atKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = atKeysInTransaction(keys)
        return sync { transaction -> ([ItemType], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map(keyForPersistable)
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}

// MARK: - Object with Object metadata

extension Readable
    where
    ItemType: NSCoding,
    ItemType: MetadataPersistable,
    ItemType.MetadataType: NSCoding {

    func inTransaction(transaction: ReadTransactionType, atIndex index: YapDB.Index) -> ItemType? {
        if var item = transaction.readAtIndex(index) as? ItemType {
            item.metadata = transaction.readMetadataAtIndex(index) as? ItemType.MetadataType
            return item
        }
        return .None
    }

    func inTransactionAtIndex(transaction: ReadTransactionType) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> ReadTransactionType -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction)) ?? []
        }
    }

    func inTransaction(transaction: ReadTransactionType, atKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionAtKey(transaction: ReadTransactionType) -> String -> ItemType? {
        return { self.inTransaction(transaction, atKey: $0) }
    }

    func atKeyInTransaction(key: String) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atKey: key) }
    }

    func atKeysInTransaction(_keys: [String]? = .None) -> ReadTransactionType -> [ItemType] {
        let atKey = inTransactionAtKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(atKey(transaction)) ?? []
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(atKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(atKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(atKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = atKeysInTransaction(keys)
        return sync { transaction -> ([ItemType], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map(keyForPersistable)
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}

// MARK: - Object with Value metadata

extension Readable
    where
    ItemType: NSCoding,
    ItemType: MetadataPersistable,
    ItemType.MetadataType: Saveable,
    ItemType.MetadataType.ArchiverType: NSCoding,
    ItemType.MetadataType.ArchiverType.ValueType == ItemType.MetadataType {

    func inTransaction(transaction: ReadTransactionType, atIndex index: YapDB.Index) -> ItemType? {
        if var item = transaction.readAtIndex(index) as? ItemType {
            item.metadata = ItemType.MetadataType.unarchive(transaction.readMetadataAtIndex(index))
            return item
        }
        return .None
    }

    func inTransactionAtIndex(transaction: ReadTransactionType) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> ReadTransactionType -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction)) ?? []
        }
    }

    func inTransaction(transaction: ReadTransactionType, atKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionAtKey(transaction: ReadTransactionType) -> String -> ItemType? {
        return { self.inTransaction(transaction, atKey: $0) }
    }

    func atKeyInTransaction(key: String) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atKey: key) }
    }

    func atKeysInTransaction(_keys: [String]? = .None) -> ReadTransactionType -> [ItemType] {
        let atKey = inTransactionAtKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(atKey(transaction)) ?? []
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(atKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(atKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(atKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = atKeysInTransaction(keys)
        return sync { transaction -> ([ItemType], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map(keyForPersistable)
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}

// MARK: - Value with no metadata

extension Readable
    where
    ItemType: Saveable,
    ItemType: Persistable,
    ItemType.ArchiverType: NSCoding,
    ItemType.ArchiverType.ValueType == ItemType {

    func inTransaction(transaction: ReadTransactionType, atIndex index: YapDB.Index) -> ItemType? {
        return ItemType.unarchive(transaction.readAtIndex(index))
    }

    func inTransactionAtIndex(transaction: ReadTransactionType) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> ReadTransactionType -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction)) ?? []
        }
    }

    func inTransaction(transaction: ReadTransactionType, atKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionAtKey(transaction: ReadTransactionType) -> String -> ItemType? {
        return { self.inTransaction(transaction, atKey: $0) }
    }

    func atKeyInTransaction(key: String) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atKey: key) }
    }

    func atKeysInTransaction(_keys: [String]? = .None) -> ReadTransactionType -> [ItemType] {
        let atKey = inTransactionAtKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(atKey(transaction)) ?? []
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(atKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(atKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(atKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = atKeysInTransaction(keys)
        return sync { transaction -> ([ItemType], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map(keyForPersistable)
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}

// MARK: - Value with Object metadata

extension Readable
    where
    ItemType: Saveable,
    ItemType: MetadataPersistable,
    ItemType.ArchiverType: NSCoding,
    ItemType.ArchiverType.ValueType == ItemType,
    ItemType.MetadataType: NSCoding {

    func inTransaction(transaction: ReadTransactionType, atIndex index: YapDB.Index) -> ItemType? {
        if var item = ItemType.unarchive(transaction.readAtIndex(index)) {
            item.metadata = transaction.readMetadataAtIndex(index) as? ItemType.MetadataType
            return item
        }
        return .None
    }

    func inTransactionAtIndex(transaction: ReadTransactionType) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> ReadTransactionType -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction)) ?? []
        }
    }

    func inTransaction(transaction: ReadTransactionType, atKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionAtKey(transaction: ReadTransactionType) -> String -> ItemType? {
        return { self.inTransaction(transaction, atKey: $0) }
    }

    func atKeyInTransaction(key: String) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atKey: key) }
    }

    func atKeysInTransaction(_keys: [String]? = .None) -> ReadTransactionType -> [ItemType] {
        let atKey = inTransactionAtKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(atKey(transaction)) ?? []
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(atKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(atKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(atKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = atKeysInTransaction(keys)
        return sync { transaction -> ([ItemType], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map(keyForPersistable)
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}

// MARK: - Value with Value metadata

extension Readable
    where
    ItemType: Saveable,
    ItemType: MetadataPersistable,
    ItemType.ArchiverType: NSCoding,
    ItemType.ArchiverType.ValueType == ItemType,
    ItemType.MetadataType: Saveable,
    ItemType.MetadataType.ArchiverType: NSCoding,
    ItemType.MetadataType.ArchiverType.ValueType == ItemType.MetadataType {

    func inTransaction(transaction: ReadTransactionType, atIndex index: YapDB.Index) -> ItemType? {
        if var item = ItemType.unarchive(transaction.readAtIndex(index)) {
            item.metadata = ItemType.MetadataType.unarchive(transaction.readMetadataAtIndex(index))
            return item
        }
        return .None
    }

    func inTransactionAtIndex(transaction: ReadTransactionType) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> ReadTransactionType -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction)) ?? []
        }
    }

    func inTransaction(transaction: ReadTransactionType, atKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionAtKey(transaction: ReadTransactionType) -> String -> ItemType? {
        return { self.inTransaction(transaction, atKey: $0) }
    }

    func atKeyInTransaction(key: String) -> ReadTransactionType -> ItemType? {
        return { self.inTransaction($0, atKey: key) }
    }

    func atKeysInTransaction(_keys: [String]? = .None) -> ReadTransactionType -> [ItemType] {
        let atKey = inTransactionAtKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(atKey(transaction)) ?? []
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(atKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(atKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(atKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = atKeysInTransaction(keys)
        return sync { transaction -> ([ItemType], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map(keyForPersistable)
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}






