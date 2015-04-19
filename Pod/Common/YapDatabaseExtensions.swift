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

public func valueFromArchive<V: Saveable where V.ArchiverType.ValueType == V>(archive: AnyObject?) -> V? {
    return archive.map { ($0 as! V.ArchiverType).value }
}

public func valuesFromArchives<V: Saveable where V.ArchiverType.ValueType == V>(archives: [AnyObject]?) -> [V]? {
    return archives?.mapOptionals { valueFromArchive($0) }
}

public func archiveFromValue<V: Saveable where V.ArchiverType.ValueType == V>(value: V?) -> V.ArchiverType? {
    return value?.archive
}

public func archivesFromValues<V: Saveable where V.ArchiverType.ValueType == V>(values: [V]?) -> [V.ArchiverType]? {
    return values?.map { $0.archive }
}

// MARK: - Persistable

extension YapDatabase {

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

public func indexForPersistable<P: Persistable>(persistable: P) -> YapDatabase.Index {
    return YapDatabase.Index(collection: persistable.dynamicType.collection, key: "\(persistable.identifier)")
}

extension YapDatabase {

    public func readValueForKey<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(key: String) -> V? {
        return newConnection().readValueForKey(key)
    }

    public func readValuesForKeys<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(keys: [String]) -> [V] {
        return newConnection().readValuesForKeys(keys)
    }

    public func readValueAtIndex<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(index: YapDatabase.Index) -> V? {
        return newConnection().readValueAtIndex(index)
    }

    public func readValuesAtIndexes<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(indexes: [YapDatabase.Index]) -> [V] {
        return newConnection().readValuesAtIndexes(indexes)
    }
    
    public func readAllValuesInCollection<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(collection: String) -> [V] {
        return newConnection().readAllValuesInCollection(collection)
    }

    public func filterExistingValuesForKeys<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(keys: [String]) -> (existing: [V], missing: [String]) {
        return newConnection().filterExistingValuesForKeys(keys)
    }

    public func readObjectForKey<O where O: Persistable>(key: String) -> O? {
        return newConnection().readObjectForKey(key)
    }

    public func readObjectsForKeys<O where O: Persistable>(keys: [String]) -> [O] {
        return newConnection().readObjectsForKeys(keys)
    }

    public func saveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> V {
        return newConnection().saveValue(value)
    }

    public func saveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> [V] {
        return newConnection().saveValues(values)
    }

    public func saveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> VM {
        return newConnection().saveValue(value)
    }

    public func saveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> [VM] {
        return newConnection().saveValues(values)
    }

    public func saveObject<O where O: NSCoding, O: Persistable>(object: O) -> O {
        return newConnection().saveObject(object)
    }

    public func saveObject<O where O: NSCoding, O: ObjectMetadataPersistable>(object: O) -> O {
        return newConnection().saveObject(object)
    }

    public func removeValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) {
        newConnection().removeValue(value)
    }

    public func removeValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) {
        newConnection().removeValues(values)
    }

    public func replaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> V {
        return newConnection().replaceValue(replacement)
    }

    public func replaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V]) -> [V] {
        return newConnection().replaceValues(replacements)
    }

    public func replaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> VM {
        return newConnection().replaceValue(replacement)
    }

    public func replaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> [VM] {
        return newConnection().replaceValues(replacements)
    }
}

extension YapDatabase {

    public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V, completion: (V) -> Void) {
        newConnection().asyncSaveValue(value, completion: completion)
    }

    func asyncSaveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V], completion: ([V]) -> Void) {
        newConnection().asyncSaveValues(values, completion: completion)
    }

    func asyncSaveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM, completion: (VM) -> Void) {
        newConnection().asyncSaveValue(value, completion: completion)
    }

    func asyncSaveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM], completion: ([VM]) -> Void) {
        newConnection().asyncSaveValues(values, completion: completion)
    }

    func asyncSaveObject<O where O: NSCoding, O: Persistable>(object: O, completion: (O) -> Void) {
        newConnection().asyncSaveObject(object, completion: completion)
    }

    func asyncSaveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM, completion: (OM) -> Void) {
        newConnection().asyncSaveObject(object, completion: completion)
    }
}

extension YapDatabase {

    public func asyncReplaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V, completion: (V) -> Void) {
        newConnection().asyncReplaceValue(replacement, completion: completion)
    }

    public func asyncReplaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V], completion: ([V]) -> Void) {
        newConnection().asyncReplaceValues(replacements, completion: completion)
    }

    public func asyncReplaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM, completion: (VM) -> Void) {
        newConnection().asyncReplaceValue(replacement, completion: completion)
    }

    public func asyncReplaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM], completion: ([VM]) -> Void) {
        newConnection().asyncReplaceValues(replacements, completion: completion)
    }
}

// MARK: - YapDatabaseConnection

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

    public func readValueForKey<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(key: String) -> V? {
        return read(readInTransactionValueForKey(key))
    }

    public func readValuesForKeys<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(keys: [String]) -> [V] {
        return read(readInTransactionValuesForKeys(keys))
    }

    public func readValueAtIndex<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(index: YapDatabase.Index) -> V? {
        return read(readInTransactionValueAtIndex(index))
    }

    public func readValuesAtIndexes<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(indexes: [YapDatabase.Index]) -> [V] {
        return read(readInTransactionValuesAtIndexes(indexes))
    }

    public func readAllValuesInCollection<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(collection: String) -> [V] {
        return self.read { $0.readAllValuesInCollection(collection) }
    }
    
    public func filterExistingValuesForKeys<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(keys: [String]) -> (existing: [V], missing: [String]) {
        return read(filterInTransactionValuesForKeys(keys))
    }

    public func readObjectForKey<O where O: Persistable>(key: String) -> O? {
        return read(readInTransactionObjectForKey(key))
    }

    public func readObjectsForKeys<O where O: Persistable>(keys: [String]) -> [O] {
        return read(readInTransactionObjectsForKeys(keys))
    }

    public func saveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> V {
        return write(saveInTransationValue(value))
    }

    public func saveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> [V] {
        return write(saveInTransationValues(values))
    }

    public func saveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> VM {
        return write(saveInTransationValue(value))
    }

    public func saveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> [VM] {
        return write(saveInTransationValues(values))
    }

    public func saveObject<O where O: NSCoding, O: Persistable>(object: O) -> O {
        return write(saveInTransationObject(object))
    }

    public func saveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> OM {
        return write(saveInTransationObject(object))
    }

    public func removeValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) {
        write(removeInTransactionValue(value))
    }

    public func removeValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) {
        write(removeInTransactionValues(values))
    }

    public func replaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> V {
        return write(replaceInTransactionValue(replacement))
    }

    public func replaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V]) -> [V] {
        return write(replaceInTransactionValues(replacements))
    }

    public func replaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> VM {
        return write(replaceInTransactionValue(replacement))
    }

    public func replaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> [VM] {
        return write(replaceInTransactionValues(replacements))
    }
}

extension YapDatabaseConnection {

    public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V, completion: (V) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveValue(value) }, completionBlock: { completion(value) })
    }

    public func asyncSaveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V], completion: ([V]) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveValues(values) }, completionBlock: { completion(values) })
    }

    public func asyncSaveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM, completion: (VM) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveValue(value) }, completionBlock: { completion(value) })
    }

    public func asyncSaveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM], completion: ([VM]) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveValues(values) }, completionBlock: { completion(values) })
    }

    public func asyncSaveObject<O where O: NSCoding, O: Persistable>(object: O, completion: (O) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveObject(object) }, completionBlock: { completion(object) })
    }

    public func asyncSaveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM, completion: (OM) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveObject(object) }, completionBlock: { completion(object) })
    }
}

extension YapDatabaseConnection {

    public func asyncReplaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V, completion: (V) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.replaceValue(replacement) }, completionBlock: { completion(replacement) })
    }

    public func asyncReplaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V], completion: ([V]) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.replaceValues(replacements) }, completionBlock: { completion(replacements) })
    }

    public func asyncReplaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM, completion: (VM) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.replaceValue(replacement) }, completionBlock: { completion(replacement) })
    }

    public func asyncReplaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM], completion: ([VM]) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.replaceValues(replacements) }, completionBlock: { completion(replacements) })
    }
}

func readInTransactionValueForKey<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(key: String) -> (YapDatabaseReadTransaction) -> V? {
    return { transaction in transaction.readValueForKey(key) }
}

func readInTransactionValuesForKeys<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(keys: [String]) -> (YapDatabaseReadTransaction) -> [V] {
    return { transaction in transaction.readValuesForKeys(keys) }
}

func readInTransactionValueAtIndex<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(index: YapDatabase.Index) -> (YapDatabaseReadTransaction) -> V? {
    return { transaction in transaction.readValueAtIndex(index) }
}

func readInTransactionValuesAtIndexes<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(indexes: [YapDatabase.Index]) -> (YapDatabaseReadTransaction) -> [V] {
    return { transaction in transaction.readValuesAtIndexes(indexes) }
}

func filterInTransactionValuesForKeys<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(keys: [String]) -> (YapDatabaseReadTransaction) -> (existing: [V], missing: [String]) {
    return { transaction in transaction.filterExistingValuesForKeys(keys) }
}

func readInTransactionObjectForKey<O where O: Persistable>(key: String) -> (YapDatabaseReadTransaction) -> O? {
    return { transaction in transaction.readObjectForKey(key) }
}

func readInTransactionObjectsForKeys<O where O: Persistable>(keys: [String]) -> (YapDatabaseReadTransaction) -> [O] {
    return { transaction in transaction.readObjectsForKeys(keys) }
}

func saveInTransationValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> (YapDatabaseReadWriteTransaction) -> V {
    return { transaction in transaction.saveValue(value) }
}

func saveInTransationValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> (YapDatabaseReadWriteTransaction) -> [V] {
    return { transaction in transaction.saveValues(values) }
}

func saveInTransationValue<V where V: Saveable, V: ValueMetadataPersistable, V.ArchiverType.ValueType == V>(value: V) -> (YapDatabaseReadWriteTransaction) -> V {
    return { transaction in transaction.saveValue(value) }
}

func saveInTransationValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> (YapDatabaseReadWriteTransaction) -> [VM] {
    return { transaction in transaction.saveValues(values) }
}

func saveInTransationObject<O where O: NSCoding, O: Persistable>(object: O) -> (YapDatabaseReadWriteTransaction) -> O {
    return { transaction in transaction.saveObject(object) }
}

func saveInTransationValues<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> (YapDatabaseReadWriteTransaction) -> OM {
    return { transaction in transaction.saveObject(object) }
}

func removeInTransactionValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> (YapDatabaseReadWriteTransaction) -> Void {
    return { transaction in transaction.removeValue(value) }
}

func removeInTransactionValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> (YapDatabaseReadWriteTransaction) -> Void {
    return { transaction in transaction.removeValues(values) }
}

func replaceInTransactionValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> (YapDatabaseReadWriteTransaction) -> V {
    return { transaction in transaction.replaceValue(replacement) }
}

func replaceInTransactionValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V]) -> (YapDatabaseReadWriteTransaction) -> [V] {
    return { transaction in transaction.replaceValues(replacements) }
}

func replaceInTransactionValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> (YapDatabaseReadWriteTransaction) -> VM {
    return { transaction in transaction.replaceValue(replacement) }
}

func replaceInTransactionValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> (YapDatabaseReadWriteTransaction) -> [VM] {
    return { transaction in transaction.replaceValues(replacements) }
}

// MARK: - YapDatabaseReadTransaction

extension YapDatabaseReadTransaction {

    public func readValueForKey<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(key: String) -> V? {
        return valueFromArchive(objectForKey(key, inCollection: V.collection))
    }

    public func readValuesForKeys<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(keys: [String]) -> [V] {
        return keys.mapOptionals(readValueForKey)
    }

    public func readValueAtIndex<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(index: YapDatabase.Index) -> V? {
        return valueFromArchive(readObjectAtIndex(index))
    }

    public func readValuesAtIndexes<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(indexes: [YapDatabase.Index]) -> [V] {
        return indexes.mapOptionals(readValueAtIndex)
    }
    
    public func readAllValuesInCollection<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(collection: String) -> [V] {
        let keys = self.allKeysInCollection(collection) as? [String]
        return self.readValuesForKeys(keys ?? [])
    }

    public func filterExistingValuesForKeys<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(keys: [String]) -> (existing: [V], missing: [String]) {
        let values: [V] = readValuesForKeys(keys)
        let existingKeys = values.map { "\($0.identifier)" }
        let missingKeys = filter(keys) { !contains(existingKeys, $0) }
        return (values, missingKeys)
    }

    public func readObjectForKey<O where O: Persistable>(key: String) -> O? {
        return objectForKey(key, inCollection: O.collection) as? O
    }

    public func readObjectsForKeys<O where O: Persistable>(keys: [String]) -> [O] {
        return keys.mapOptionals(readObjectForKey)
    }

    public func readObjectAtIndex(index: YapDatabase.Index) -> AnyObject? {
        return objectForKey(index.key, inCollection: index.collection)
    }

    public func readObjectsAtIndexes(indexes: [YapDatabase.Index]) -> [AnyObject] {
        return indexes.mapOptionals(readObjectAtIndex)
    }
}

// MARK: - YapDatabaseReadWriteTransaction

extension YapDatabaseReadWriteTransaction {

    public func saveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> V {
        setObject(value.archive, forKey: "\(value.identifier)", inCollection: value.dynamicType.collection)
        return value
    }

    public func saveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> [V] {
        values.map(saveValue)
        return values
    }

    public func saveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> VM {
        setObject(value.archive, forKey: "\(value.identifier)", inCollection: value.dynamicType.collection, withMetadata: value.metadata.archive)
        return value
    }

    public func saveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> [VM] {
        values.map(saveValue)
        return values
    }

    public func saveObject<O where O: NSCoding, O: Persistable>(object: O) -> O {
        setObject(object, forKey: "\(object.identifier)", inCollection: object.dynamicType.collection)
        return object
    }

    public func saveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> OM {
        setObject(object, forKey: "\(object.identifier)", inCollection: object.dynamicType.collection, withMetadata: object.metadata)
        return object
    }

    public func removeValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) {
        removeObjectForKey("\(value.identifier)", inCollection: value.dynamicType.collection)
    }

    public func removeValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) {
        removeObjectsForKeys(values.map { "\($0.identifier)" }, inCollection: V.collection)
    }

    public func replaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> V {
        replaceObject(replacement.archive, forKey: "\(replacement.identifier)", inCollection: replacement.dynamicType.collection)
        return replacement
    }

    public func replaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V]) -> [V] {
        replacements.map(replaceValue)
        return replacements
    }

    public func replaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> VM {
        replaceObject(replacement.archive, forKey: "\(replacement.identifier)", inCollection: replacement.dynamicType.collection)
        replaceMetadata(replacement.metadata.archive, forKey: "\(replacement.identifier)", inCollection: replacement.dynamicType.collection)
        return replacement
    }

    public func replaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> [VM] {
        replacements.map(replaceValue)
        return replacements
    }
}

// MARK: - Helpers

extension Array {

    internal func mapOptionals<U>(optional: (T) -> U?) -> Array<U> {
        return filter { optional($0) != nil }.map { optional($0)! }
    }
}
