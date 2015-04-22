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

public func valueFromArchive<Value: Saveable where Value.ArchiverType.ValueType == Value>(archive: AnyObject?) -> Value? {
    return archive.map { ($0 as! Value.ArchiverType).value }
}

public func valuesFromArchives<Value: Saveable where Value.ArchiverType.ValueType == Value>(archives: [AnyObject]?) -> [Value]? {
    return archives?.mapOptionals { valueFromArchive($0) }
}

public func archiveFromValue<Value: Saveable where Value.ArchiverType.ValueType == Value>(value: Value?) -> Value.ArchiverType? {
    return value?.archive
}

public func archivesFromValues<Value: Saveable where Value.ArchiverType.ValueType == Value>(values: [Value]?) -> [Value.ArchiverType]? {
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

internal func map<S: SequenceType, T>(source: S, transform: (S.Generator.Element) -> T?) -> [T] {
    return reduce(source, [T](), { (var accumulator, element) -> [T] in
        if let transformed = transform(element) {
            accumulator.append(transformed)
        }
        return accumulator
    })
}


// MARK: - Pure Functional API: Reading Value(s)

public func readInTransactionValueForKey<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> (YapDatabaseReadTransaction) -> Value? {
    return { $0.readValueForKey(key) }
}

public func readInTransactionValuesForKeys<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> (YapDatabaseReadTransaction) -> [Value] {
    return { $0.readValuesForKeys(keys) }
}

public func readInTransactionValueAtIndex<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(index: YapDatabase.Index) -> (YapDatabaseReadTransaction) -> Value? {
    return { $0.readValueAtIndex(index) }
}

public func readInTransactionValuesAtIndexes<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(indexes: [YapDatabase.Index]) -> (YapDatabaseReadTransaction) -> [Value] {
    return { $0.readValuesAtIndexes(indexes) }
}

public func filterInTransactionValuesForKeys<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> (YapDatabaseReadTransaction) -> (existing: [Value], missing: [String]) {
    return { $0.filterExistingValuesForKeys(keys) }
}

public func readInTransactionObjectForKey<Object where Object: Persistable>(key: String) -> (YapDatabaseReadTransaction) -> Object? {
    return { $0.readObjectForKey(key) }
}

public func readInTransactionObjectsForKeys<Object where Object: Persistable>(keys: [String]) -> (YapDatabaseReadTransaction) -> [Object] {
    return { $0.readObjectsForKeys(keys) }
}

// MARK: - Pure Functional API: Saving Value(s)

public func saveInTransationValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> (YapDatabaseReadWriteTransaction) -> Value {
    return { $0.saveValue(value) }
}

public func saveInTransationValues<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> (YapDatabaseReadWriteTransaction) -> [Value] {
    return { $0.saveValues(values) }
}

public func saveInTransationValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(value: Value) -> (YapDatabaseReadWriteTransaction) -> Value {
    return { $0.saveValue(value) }
}

public func saveInTransationValues<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(values: Values) -> (YapDatabaseReadWriteTransaction) -> [Value] {
    return { $0.saveValues(values) }
}

public func saveInTransationObject<Object where Object: NSCoding, Object: Persistable>(object: Object) -> (YapDatabaseReadWriteTransaction) -> Object {
    return { $0.saveObject(object) }
}

public func saveInTransationObject<Object where Object: NSCoding, Object: ObjectMetadataPersistable>(object: Object) -> (YapDatabaseReadWriteTransaction) -> Object {
    return { $0.saveObject(object) }
}

// MARK: - Pure Functional API: Removing Value(s)

public func removeInTransactionValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> (YapDatabaseReadWriteTransaction) -> Void {
    return { $0.removeValue(value) }
}

public func removeInTransactionValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: [Value]) -> (YapDatabaseReadWriteTransaction) -> Void {
    return { $0.removeValues(values) }
}

// MARK: - Pure Functional API: Replacing Value(s)

public func replaceInTransactionValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacement: Value) -> (YapDatabaseReadWriteTransaction) -> Value {
    return { $0.replaceValue(replacement) }
}

public func replaceInTransactionValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacements: [Value]) -> (YapDatabaseReadWriteTransaction) -> [Value] {
    return { $0.replaceValues(replacements) }
}

public func replaceInTransactionValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> (YapDatabaseReadWriteTransaction) -> VM {
    return { $0.replaceValue(replacement) }
}

public func replaceInTransactionValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> (YapDatabaseReadWriteTransaction) -> [VM] {
    return { $0.replaceValues(replacements) }
}


// MARK: - YapDatabaseReadWriteTransaction

extension YapDatabaseReadWriteTransaction {

    public func saveValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Value {
        setObject(value.archive, forKey: "\(value.identifier)", inCollection: value.dynamicType.collection)
        return value
    }

    public func saveValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Value {
        setObject(value.archive, forKey: "\(value.identifier)", inCollection: value.dynamicType.collection, withMetadata: value.metadata.archive)
        return value
    }

    public func saveValues<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> [Value] {
        return map(values, saveValue)
    }

    public func saveValues<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(values: Values) -> [Value] {
        return map(values, saveValue)
    }

}

extension YapDatabaseReadWriteTransaction {

    public func saveObject<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Object {
        setObject(object, forKey: "\(object.identifier)", inCollection: object.dynamicType.collection)
        return object
    }

    public func saveObject<Object where Object: NSCoding, Object: ObjectMetadataPersistable>(object: Object) -> Object {
        setObject(object, forKey: "\(object.identifier)", inCollection: object.dynamicType.collection, withMetadata: object.metadata)
        return object
    }

    public func saveObjects<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> [Object] {
        return map(objects, saveObject)
    }

    public func saveObjects<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: ObjectMetadataPersistable>(objects: Objects) -> [Object] {
        return map(objects, saveObject)
    }
}

extension YapDatabaseReadWriteTransaction {

    public func removeValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) {
        removeObjectForKey("\(value.identifier)", inCollection: value.dynamicType.collection)
    }

    public func removeValues<S where S: SequenceType, S.Generator.Element: Persistable>(values: S) {
        removeObjectsForKeys(map(values, { "\($0.identifier)" }), inCollection: S.Generator.Element.collection)
    }
}

extension YapDatabaseReadWriteTransaction {

    public func replaceValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacement: Value) -> Value {
        replaceObject(replacement.archive, forKey: "\(replacement.identifier)", inCollection: replacement.dynamicType.collection)
        return replacement
    }

    public func replaceValues<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacements: Values) -> [Value] {
        return map(replacements, replaceValue)
    }

    public func replaceValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(replacement: Value) -> Value {
        replaceObject(replacement.archive, forKey: "\(replacement.identifier)", inCollection: replacement.dynamicType.collection)
        replaceMetadata(replacement.metadata.archive, forKey: "\(replacement.identifier)", inCollection: replacement.dynamicType.collection)
        return replacement
    }

    public func replaceValues<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(replacements: Values) -> [Value] {
        return map(replacements, replaceValue)
    }
}

// MARK: - YapDatabaseReadTransaction

extension YapDatabaseReadTransaction {

    public func readValueForKey<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> Value? {
        return valueFromArchive(objectForKey(key, inCollection: Value.collection))
    }

    public func readValuesForKeys<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> [Value] {
        return keys.mapOptionals(readValueForKey)
    }

    public func readValueAtIndex<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(index: YapDatabase.Index) -> Value? {
        return valueFromArchive(readObjectAtIndex(index))
    }

    public func readValuesAtIndexes<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(indexes: [YapDatabase.Index]) -> [Value] {
        return indexes.mapOptionals(readValueAtIndex)
    }

    public func readAllValuesInCollection<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(collection: String) -> [Value] {
        let keys = allKeysInCollection(collection) as? [String]
        return readValuesForKeys(keys ?? [])
    }

    public func filterExistingValuesForKeys<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> (existing: [Value], missing: [String]) {
        let values: [Value] = readValuesForKeys(keys)
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

extension YapDatabase {

    public func readValueForKey<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> Value? {
        return newConnection().readValueForKey(key)
    }

    public func readValuesForKeys<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> [Value] {
        return newConnection().readValuesForKeys(keys)
    }

    public func readValueAtIndex<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(index: YapDatabase.Index) -> Value? {
        return newConnection().readValueAtIndex(index)
    }

    public func readValuesAtIndexes<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(indexes: [YapDatabase.Index]) -> [Value] {
        return newConnection().readValuesAtIndexes(indexes)
    }
    
    public func readAllValuesInCollection<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(collection: String) -> [Value] {
        return newConnection().readAllValuesInCollection(collection)
    }

    public func filterExistingValuesForKeys<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> (existing: [Value], missing: [String]) {
        return newConnection().filterExistingValuesForKeys(keys)
    }

    public func readObjectForKey<O where O: Persistable>(key: String) -> O? {
        return newConnection().readObjectForKey(key)
    }

    public func readObjectsForKeys<O where O: Persistable>(keys: [String]) -> [O] {
        return newConnection().readObjectsForKeys(keys)
    }

    public func saveValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Value {
        return newConnection().saveValue(value)
    }

    public func saveValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: [Value]) -> [Value] {
        return newConnection().saveValues(values)
    }

    public func saveValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Value {
        return newConnection().saveValue(value)
    }

    public func saveValues<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(values: [Value]) -> [Value] {
        return newConnection().saveValues(values)
    }

    public func saveObject<O where O: NSCoding, O: Persistable>(object: O) -> O {
        return newConnection().saveObject(object)
    }

    public func saveObject<O where O: NSCoding, O: ObjectMetadataPersistable>(object: O) -> O {
        return newConnection().saveObject(object)
    }

    public func removeValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) {
        newConnection().removeValue(value)
    }

    public func removeValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: [Value]) {
        newConnection().removeValues(values)
    }

    public func replaceValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacement: Value) -> Value {
        return newConnection().replaceValue(replacement)
    }

    public func replaceValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacements: [Value]) -> [Value] {
        return newConnection().replaceValues(replacements)
    }

    public func replaceValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(replacement: Value) -> Value {
        return newConnection().replaceValue(replacement)
    }

    public func replaceValues<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(replacements: [Value]) -> [Value] {
        return newConnection().replaceValues(replacements)
    }
}

extension YapDatabase {

    public func asyncSaveValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value, completion: (Value) -> Void) {
        newConnection().asyncSaveValue(value, completion: completion)
    }

    func asyncSaveValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: [Value], completion: ([Value]) -> Void) {
        newConnection().asyncSaveValues(values, completion: completion)
    }

    func asyncSaveValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(value: Value, completion: (Value) -> Void) {
        newConnection().asyncSaveValue(value, completion: completion)
    }

    func asyncSaveValues<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(values: [Value], completion: ([Value]) -> Void) {
        newConnection().asyncSaveValues(values, completion: completion)
    }

    func asyncSaveObject<Object where Object: NSCoding, Object: Persistable>(object: Object, completion: (Object) -> Void) {
        newConnection().asyncSaveObject(object, completion: completion)
    }

    func asyncSaveObject<Object where Object: NSCoding, Object: ObjectMetadataPersistable>(object: Object, completion: (Object) -> Void) {
        newConnection().asyncSaveObject(object, completion: completion)
    }
}

extension YapDatabase {

    public func asyncReplaceValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacement: Value, completion: (Value) -> Void) {
        newConnection().asyncReplaceValue(replacement, completion: completion)
    }

    public func asyncReplaceValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacements: [Value], completion: ([Value]) -> Void) {
        newConnection().asyncReplaceValues(replacements, completion: completion)
    }

    public func asyncReplaceValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(replacement: Value, completion: (Value) -> Void) {
        newConnection().asyncReplaceValue(replacement, completion: completion)
    }

    public func asyncReplaceValues<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(replacements: [Value], completion: ([Value]) -> Void) {
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

    public func readValueForKey<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> Value? {
        return read(readInTransactionValueForKey(key))
    }

    public func readValuesForKeys<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> [Value] {
        return read(readInTransactionValuesForKeys(keys))
    }

    public func readValueAtIndex<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(index: YapDatabase.Index) -> Value? {
        return read(readInTransactionValueAtIndex(index))
    }

    public func readValuesAtIndexes<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(indexes: [YapDatabase.Index]) -> [Value] {
        return read(readInTransactionValuesAtIndexes(indexes))
    }

    public func readAllValuesInCollection<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(collection: String) -> [Value] {
        return read { $0.readAllValuesInCollection(collection) }
    }
    
    public func filterExistingValuesForKeys<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> (existing: [Value], missing: [String]) {
        return read(filterInTransactionValuesForKeys(keys))
    }

    public func readObjectForKey<Object where Object: Persistable>(key: String) -> Object? {
        return read(readInTransactionObjectForKey(key))
    }

    public func readObjectsForKeys<Object where Object: Persistable>(keys: [String]) -> [Object] {
        return read(readInTransactionObjectsForKeys(keys))
    }

    public func saveValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Value {
        return write(saveInTransationValue(value))
    }

    public func saveValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: [Value]) -> [Value] {
        return write(saveInTransationValues(values))
    }

    public func saveValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Value {
        return write(saveInTransationValue(value))
    }

    public func saveValues<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(values: [Value]) -> [Value] {
        return write(saveInTransationValues(values))
    }

    public func saveObject<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Object {
        return write(saveInTransationObject(object))
    }

    public func saveObject<Object where Object: NSCoding, Object: ObjectMetadataPersistable>(object: Object) -> Object {
        return write(saveInTransationObject(object))
    }

    public func removeValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) {
        write(removeInTransactionValue(value))
    }

    public func removeValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: [Value]) {
        write(removeInTransactionValues(values))
    }

    public func replaceValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacement: Value) -> Value {
        return write(replaceInTransactionValue(replacement))
    }

    public func replaceValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacements: [Value]) -> [Value] {
        return write(replaceInTransactionValues(replacements))
    }

    public func replaceValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(replacement: Value) -> Value {
        return write(replaceInTransactionValue(replacement))
    }

    public func replaceValues<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(replacements: [Value]) -> [Value] {
        return write(replaceInTransactionValues(replacements))
    }
}

extension YapDatabaseConnection {

    public func asyncSaveValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value, completion: (Value) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveValue(value) }, completionBlock: { completion(value) })
    }

    public func asyncSaveValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: [Value], completion: ([Value]) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveValues(values) }, completionBlock: { completion(values) })
    }

    public func asyncSaveValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(value: Value, completion: (Value) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveValue(value) }, completionBlock: { completion(value) })
    }

    public func asyncSaveValues<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(values: [Value], completion: ([Value]) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveValues(values) }, completionBlock: { completion(values) })
    }

    public func asyncSaveObject<Object where Object: NSCoding, Object: Persistable>(object: Object, completion: (Object) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveObject(object) }, completionBlock: { completion(object) })
    }

    public func asyncSaveObject<Object where Object: NSCoding, Object: ObjectMetadataPersistable>(object: Object, completion: (Object) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.saveObject(object) }, completionBlock: { completion(object) })
    }
}

extension YapDatabaseConnection {

    public func asyncReplaceValue<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacement: Value, completion: (Value) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.replaceValue(replacement) }, completionBlock: { completion(replacement) })
    }

    public func asyncReplaceValues<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(replacements: [Value], completion: ([Value]) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.replaceValues(replacements) }, completionBlock: { completion(replacements) })
    }

    public func asyncReplaceValue<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(replacement: Value, completion: (Value) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.replaceValue(replacement) }, completionBlock: { completion(replacement) })
    }

    public func asyncReplaceValues<Value where Value: Saveable, Value: ValueMetadataPersistable, Value.ArchiverType.ValueType == Value>(replacements: [Value], completion: ([Value]) -> Void) {
        asyncReadWriteWithBlock({ transaction in let _ = transaction.replaceValues(replacements) }, completionBlock: { completion(replacements) })
    }
}

// MARK: - Helpers

extension Array {

    internal func mapOptionals<U>(optional: (T) -> U?) -> Array<U> {
        return filter { optional($0) != nil }.map { optional($0)! }
    }
}
