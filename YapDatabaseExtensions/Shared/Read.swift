//
//  Created by Daniel Thorpe on 22/04/2015.
//
//

import Foundation
import ValueCoding
import YapDatabase

// MARK: - Readable

public protocol Readable {
    typealias ItemType
    typealias Database: DatabaseType

    var transaction: Database.Connection.ReadTransaction? { get }
    var connection: Database.Connection { get }
}

public struct Read<Item, D: DatabaseType>: Readable {
    public typealias ItemType = Item
    public typealias Database = D

    let reader: Handle<D>

    public var transaction: D.Connection.ReadTransaction? {
        if case let .Transaction(transaction) = reader {
            return transaction
        }
        return .None
    }

    public var connection: D.Connection {
        switch reader {
        case .Transaction(_):
            fatalError("Attempting to get connection from a transaction.")
        case .Connection(let connection):
            return connection
        default:
            return database.makeNewConnection()
        }
    }

    internal var database: D {
        if case let .Database(database) = reader {
            return database
        }
        fatalError("Attempting to get database from \(reader)")
    }

    internal init(_ transaction: D.Connection.ReadTransaction) {
        reader = .Transaction(transaction)
    }

    internal init(_ connection: D.Connection) {
        reader = .Connection(connection)
    }

    internal init(_ database: D) {
        reader = .Database(database)
    }
}

extension Persistable {

    /**
    Returns a type suitable for *reading* from the transaction. The available
    functions will depend on your own types correctly implementing Persistable,
    MetadataPersistable and ValueCoding.
    
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
    public static func read(transaction: YapDatabaseReadTransaction) -> Read<Self, YapDatabase> {
        return Read(transaction)
    }

    /**
    Returns a type suitable for Reading from a database connection. The available
    functions will depend on your own types correctly implementing Persistable,
    MetadataPersistable and ValueCoding.

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
    public static func read(connection: YapDatabaseConnection) -> Read<Self, YapDatabase> {
        return Read(connection)
    }

    internal static func read(database: YapDatabase) -> Read<Self, YapDatabase> {
        return Read(database)
    }
}

extension Readable
    where
    ItemType: Persistable {

    func sync<T>(block: (Database.Connection.ReadTransaction) -> T) -> T {
        if let transaction = transaction {
            return block(transaction)
        }
        return connection.read(block)
    }
}

// MARK: - Object with no metadata

extension Readable
    where
    ItemType: NSCoding,
    ItemType: Persistable {

    func inTransaction(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType? {
        return transaction.readAtIndex(index) as? ItemType
    }

    // Everything here is the same for all 6 patterns.

    func inTransactionAtIndex(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> Database.Connection.ReadTransaction -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction))
        }
    }

    func inTransaction(transaction: Database.Connection.ReadTransaction, byKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionByKey(transaction: Database.Connection.ReadTransaction) -> String -> ItemType? {
        return { self.inTransaction(transaction, byKey: $0) }
    }

    func byKeyInTransaction(key: String) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, byKey: key) }
    }

    func byKeysInTransaction(_keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [ItemType] {
        let byKey = inTransactionByKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(byKey(transaction))
        }
    }



    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(byKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(byKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(byKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = byKeysInTransaction(keys)
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

    func inTransaction(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType? {
        return transaction.readAtIndex(index)
    }

    // Everything here is the same for all 6 patterns.

    func inTransactionAtIndex(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> Database.Connection.ReadTransaction -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction))
        }
    }

    func inTransaction(transaction: Database.Connection.ReadTransaction, byKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionByKey(transaction: Database.Connection.ReadTransaction) -> String -> ItemType? {
        return { self.inTransaction(transaction, byKey: $0) }
    }

    func byKeyInTransaction(key: String) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, byKey: key) }
    }

    func byKeysInTransaction(_keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [ItemType] {
        let byKey = inTransactionByKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(byKey(transaction))
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(byKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(byKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(byKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = byKeysInTransaction(keys)
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
    ItemType.MetadataType: ValueCoding,
    ItemType.MetadataType.Coder: NSCoding,
    ItemType.MetadataType.Coder.ValueType == ItemType.MetadataType {

    func inTransaction(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType? {
        return transaction.readAtIndex(index)
    }

    // Everything here is the same for all 6 patterns.

    func inTransactionAtIndex(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> Database.Connection.ReadTransaction -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction))
        }
    }

    func inTransaction(transaction: Database.Connection.ReadTransaction, byKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionByKey(transaction: Database.Connection.ReadTransaction) -> String -> ItemType? {
        return { self.inTransaction(transaction, byKey: $0) }
    }

    func byKeyInTransaction(key: String) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, byKey: key) }
    }

    func byKeysInTransaction(_keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [ItemType] {
        let byKey = inTransactionByKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(byKey(transaction))
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(byKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(byKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(byKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = byKeysInTransaction(keys)
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
    ItemType: ValueCoding,
    ItemType: Persistable,
    ItemType.Coder: NSCoding,
    ItemType.Coder.ValueType == ItemType {

    func inTransaction(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType? {
        return ItemType.decode(transaction.readAtIndex(index))
    }

    // Everything here is the same for all 6 patterns.

    func inTransactionAtIndex(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> Database.Connection.ReadTransaction -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction))
        }
    }

    func inTransaction(transaction: Database.Connection.ReadTransaction, byKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionByKey(transaction: Database.Connection.ReadTransaction) -> String -> ItemType? {
        return { self.inTransaction(transaction, byKey: $0) }
    }

    func byKeyInTransaction(key: String) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, byKey: key) }
    }

    func byKeysInTransaction(_keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [ItemType] {
        let byKey = inTransactionByKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(byKey(transaction))
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(byKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(byKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(byKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = byKeysInTransaction(keys)
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
    ItemType: ValueCoding,
    ItemType: MetadataPersistable,
    ItemType.Coder: NSCoding,
    ItemType.Coder.ValueType == ItemType,
    ItemType.MetadataType: NSCoding {

    func inTransaction(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType? {
        return transaction.readAtIndex(index)
    }

    // Everything here is the same for all 6 patterns.

    func inTransactionAtIndex(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> Database.Connection.ReadTransaction -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction))
        }
    }

    func inTransaction(transaction: Database.Connection.ReadTransaction, byKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionByKey(transaction: Database.Connection.ReadTransaction) -> String -> ItemType? {
        return { self.inTransaction(transaction, byKey: $0) }
    }

    func byKeyInTransaction(key: String) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, byKey: key) }
    }

    func byKeysInTransaction(_keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [ItemType] {
        let byKey = inTransactionByKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(byKey(transaction))
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(byKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(byKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(byKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = byKeysInTransaction(keys)
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
    ItemType: ValueCoding,
    ItemType: MetadataPersistable,
    ItemType.Coder: NSCoding,
    ItemType.Coder.ValueType == ItemType,
    ItemType.MetadataType: ValueCoding,
    ItemType.MetadataType.Coder: NSCoding,
    ItemType.MetadataType.Coder.ValueType == ItemType.MetadataType {

    func inTransaction(transaction: Database.Connection.ReadTransaction, atIndex index: YapDB.Index) -> ItemType? {
        return transaction.readAtIndex(index)
    }

    // Everything here is the same for all 6 patterns.

    func inTransactionAtIndex(transaction: Database.Connection.ReadTransaction) -> YapDB.Index -> ItemType? {
        return { self.inTransaction(transaction, atIndex: $0) }
    }

    func atIndexInTransaction(index: YapDB.Index) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, atIndex: index) }
    }

    func atIndexesInTransaction(indexes: [YapDB.Index]) -> Database.Connection.ReadTransaction -> [ItemType] {
        let atIndex = inTransactionAtIndex
        return { transaction in
            indexes.flatMap(atIndex(transaction))
        }
    }

    func inTransaction(transaction: Database.Connection.ReadTransaction, byKey key: String) -> ItemType? {
        return inTransaction(transaction, atIndex: ItemType.indexWithKey(key))
    }

    func inTransactionByKey(transaction: Database.Connection.ReadTransaction) -> String -> ItemType? {
        return { self.inTransaction(transaction, byKey: $0) }
    }

    func byKeyInTransaction(key: String) -> Database.Connection.ReadTransaction -> ItemType? {
        return { self.inTransaction($0, byKey: key) }
    }

    func byKeysInTransaction(_keys: [String]? = .None) -> Database.Connection.ReadTransaction -> [ItemType] {
        let byKey = inTransactionByKey
        return { transaction in
            let keys = _keys ?? transaction.keysInCollection(ItemType.collection)
            return keys.flatMap(byKey(transaction))
        }
    }

    public func atIndex(index: YapDB.Index) -> ItemType? {
        return sync(atIndexInTransaction(index))
    }

    public func atIndexes(indexes: [YapDB.Index]) -> [ItemType] {
        return sync(atIndexesInTransaction(indexes))
    }

    public func byKey(key: String) -> ItemType? {
        return sync(byKeyInTransaction(key))
    }

    public func byKeys(keys: [String]) -> [ItemType] {
        return sync(byKeysInTransaction(keys))
    }

    public func all() -> [ItemType] {
        return sync(byKeysInTransaction())
    }

    public func filterExisting(keys: [String]) -> (existing: [ItemType], missing: [String]) {
        let existingInTransaction = byKeysInTransaction(keys)
        return sync { transaction -> ([ItemType], [String]) in
            let existing = existingInTransaction(transaction)
            let existingKeys = existing.map(keyForPersistable)
            let missingKeys = keys.filter { !existingKeys.contains($0) }
            return (existing, missingKeys)
        }
    }
}


// MARK: - Object with Object metadata

extension ReadTransactionType {

    public func readAtIndex<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(index: YapDB.Index) -> ObjectWithObjectMetadata? {
            if var item = readAtIndex(index) as? ObjectWithObjectMetadata {
                item.metadata = readMetadataAtIndex(index) as? ObjectWithObjectMetadata.MetadataType
                return item
            }
            return .None
    }

    public func readAtIndexes<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(indexes: [YapDB.Index]) -> [ObjectWithObjectMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    public func readByKey<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(key: String) -> ObjectWithObjectMetadata? {
            return readAtIndex(ObjectWithObjectMetadata.indexWithKey(key))
    }

    public func readByKeys<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(keys: [String]) -> [ObjectWithObjectMetadata] {
            return readAtIndexes(ObjectWithObjectMetadata.indexesWithKeys(keys))
    }
}

extension ConnectionType {

    public func readAtIndex<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(index: YapDB.Index) -> ObjectWithObjectMetadata? {
            return read { $0.readAtIndex(index) }
    }

    public func readAtIndexes<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(indexes: [YapDB.Index]) -> [ObjectWithObjectMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    public func readByKey<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(key: String) -> ObjectWithObjectMetadata? {
            return readAtIndex(ObjectWithObjectMetadata.indexWithKey(key))
    }

    public func readByKeys<
        ObjectWithObjectMetadata
        where
        ObjectWithObjectMetadata: MetadataPersistable,
        ObjectWithObjectMetadata: NSCoding,
        ObjectWithObjectMetadata.MetadataType: NSCoding>(keys: [String]) -> [ObjectWithObjectMetadata] {
            return readAtIndexes(ObjectWithObjectMetadata.indexesWithKeys(keys))
    }
}

// MARK: - Object with Value metadata

extension ReadTransactionType {

    public func readAtIndex<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(index: YapDB.Index) -> ObjectWithValueMetadata? {
            if var item = readAtIndex(index) as? ObjectWithValueMetadata {
                item.metadata = ObjectWithValueMetadata.MetadataType.decode(readMetadataAtIndex(index))
                return item
            }
            return .None
    }

    public func readAtIndexes<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(indexes: [YapDB.Index]) -> [ObjectWithValueMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    public func readByKey<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(key: String) -> ObjectWithValueMetadata? {
            return readAtIndex(ObjectWithValueMetadata.indexWithKey(key))
    }

    public func readByKeys<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(keys: [String]) -> [ObjectWithValueMetadata] {
            return readAtIndexes(ObjectWithValueMetadata.indexesWithKeys(keys))
    }
}

extension ConnectionType {

    public func readAtIndex<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(index: YapDB.Index) -> ObjectWithValueMetadata? {
            return read { $0.readAtIndex(index) }
    }

    public func readAtIndexes<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(indexes: [YapDB.Index]) -> [ObjectWithValueMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    public func readByKey<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(key: String) -> ObjectWithValueMetadata? {
            return readAtIndex(ObjectWithValueMetadata.indexWithKey(key))
    }

    public func readByKeys<
        ObjectWithValueMetadata
        where
        ObjectWithValueMetadata: MetadataPersistable,
        ObjectWithValueMetadata: NSCoding,
        ObjectWithValueMetadata.MetadataType: ValueCoding,
        ObjectWithValueMetadata.MetadataType.Coder: NSCoding,
        ObjectWithValueMetadata.MetadataType.Coder.ValueType == ObjectWithValueMetadata.MetadataType>(keys: [String]) -> [ObjectWithValueMetadata] {
            return readAtIndexes(ObjectWithValueMetadata.indexesWithKeys(keys))
    }
}

// MARK: - Value with Object metadata

extension ReadTransactionType {

    public func readAtIndex<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(index: YapDB.Index) -> ValueWithObjectMetadata? {
            if var item = ValueWithObjectMetadata.decode(readAtIndex(index)) {
                item.metadata = readMetadataAtIndex(index) as? ValueWithObjectMetadata.MetadataType
                return item
            }
            return .None
    }

    public func readAtIndexes<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(indexes: [YapDB.Index]) -> [ValueWithObjectMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    public func readByKey<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(key: String) -> ValueWithObjectMetadata? {
            return readAtIndex(ValueWithObjectMetadata.indexWithKey(key))
    }

    public func readByKeys<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(keys: [String]) -> [ValueWithObjectMetadata] {
            return readAtIndexes(ValueWithObjectMetadata.indexesWithKeys(keys))
    }
}

extension ConnectionType {

    public func readAtIndex<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(index: YapDB.Index) -> ValueWithObjectMetadata? {
            return read { $0.readAtIndex(index) }
    }

    public func readAtIndexes<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(indexes: [YapDB.Index]) -> [ValueWithObjectMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    public func readByKey<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(key: String) -> ValueWithObjectMetadata? {
            return readAtIndex(ValueWithObjectMetadata.indexWithKey(key))
    }

    public func readByKeys<
        ValueWithObjectMetadata
        where
        ValueWithObjectMetadata: MetadataPersistable,
        ValueWithObjectMetadata: ValueCoding,
        ValueWithObjectMetadata.Coder: NSCoding,
        ValueWithObjectMetadata.Coder.ValueType == ValueWithObjectMetadata,
        ValueWithObjectMetadata.MetadataType: NSCoding>(keys: [String]) -> [ValueWithObjectMetadata] {
            return readAtIndexes(ValueWithObjectMetadata.indexesWithKeys(keys))
    }
}

// MARK: - Value with Value metadata

extension ReadTransactionType {

    public func readAtIndex<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(index: YapDB.Index) -> ValueWithValueMetadata? {
            if var item = ValueWithValueMetadata.decode(readAtIndex(index)) {
                item.metadata = ValueWithValueMetadata.MetadataType.decode(readMetadataAtIndex(index))
                return item
            }
            return .None
    }

    public func readAtIndexes<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(indexes: [YapDB.Index]) -> [ValueWithValueMetadata] {
            return indexes.flatMap(readAtIndex)
    }

    public func readByKey<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(key: String) -> ValueWithValueMetadata? {
            return readAtIndex(ValueWithValueMetadata.indexWithKey(key))
    }

    public func readByKeys<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(keys: [String]) -> [ValueWithValueMetadata] {
            return readAtIndexes(ValueWithValueMetadata.indexesWithKeys(keys))
    }
}

extension ConnectionType {

    public func readAtIndex<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(index: YapDB.Index) -> ValueWithValueMetadata? {
            return read { $0.readAtIndex(index) }
    }

    public func readAtIndexes<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(indexes: [YapDB.Index]) -> [ValueWithValueMetadata] {
            return read { $0.readAtIndexes(indexes) }
    }

    public func readByKey<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(key: String) -> ValueWithValueMetadata? {
            return readAtIndex(ValueWithValueMetadata.indexWithKey(key))
    }

    public func readByKeys<
        ValueWithValueMetadata
        where
        ValueWithValueMetadata: MetadataPersistable,
        ValueWithValueMetadata: ValueCoding,
        ValueWithValueMetadata.Coder: NSCoding,
        ValueWithValueMetadata.Coder.ValueType == ValueWithValueMetadata,
        ValueWithValueMetadata.MetadataType: ValueCoding,
        ValueWithValueMetadata.MetadataType.Coder: NSCoding,
        ValueWithValueMetadata.MetadataType.Coder.ValueType == ValueWithValueMetadata.MetadataType>(keys: [String]) -> [ValueWithValueMetadata] {
            return readAtIndexes(ValueWithValueMetadata.indexesWithKeys(keys))
    }
}





