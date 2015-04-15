//
//  Created by Daniel Thorpe on 08/04/2015.
//

import YapDatabase
import BrightFutures

// MARK: - YapDatabase

extension YapDatabase {

    public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> Future<V> {
        let promise = Promise<V>()
        asyncSaveValue(value) { promise.success($0) }
        return promise.future
    }

    public func asyncSaveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> Future<[V]> {
        let promise = Promise<[V]>()
        asyncSaveValues(values) { promise.success($0) }
        return promise.future
    }

    public func asyncSaveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> Future<VM> {
        let promise = Promise<VM>()
        asyncSaveValue(value) { promise.success($0) }
        return promise.future
    }

    public func asyncSaveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> Future<[VM]> {
        let promise = Promise<[VM]>()
        asyncSaveValues(values) { promise.success($0) }
        return promise.future
    }

    public func asyncSaveObject<O where O: NSCoding, O: Persistable>(object: O) -> Future<O> {
        let promise = Promise<O>()
        asyncSaveObject(object) { promise.success($0) }
        return promise.future
    }

    public func asyncSaveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> Future<OM> {
        let promise = Promise<OM>()
        asyncSaveObject(object) { promise.success($0) }
        return promise.future
    }
}

extension YapDatabase {

    public func asyncReplaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> Future<V> {
        let promise = Promise<V>()
        asyncReplaceValue(replacement) { promise.success($0) }
        return promise.future
    }

    public func asyncReplaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V]) -> Future<[V]> {
        let promise = Promise<[V]>()
        asyncReplaceValues(replacements) { promise.success($0) }
        return promise.future
    }

    public func asyncReplaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> Future<VM> {
        let promise = Promise<VM>()
        asyncReplaceValue(replacement) { promise.success($0) }
        return promise.future
    }

    public func asyncReplaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> Future<[VM]> {
        let promise = Promise<[VM]>()
        asyncReplaceValues(replacements) { promise.success($0) }
        return promise.future
    }
}

// MARK: - YapDatabaseConnection

extension YapDatabaseConnection {

    public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> Future<V> {
        let promise = Promise<V>()
        asyncSaveValue(value) { promise.success($0) }
        return promise.future
    }

    public func asyncSaveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> Future<[V]> {
        let promise = Promise<[V]>()
        asyncSaveValues(values) { promise.success($0) }
        return promise.future
    }

    public func asyncSaveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> Future<VM> {
        let promise = Promise<VM>()
        asyncSaveValue(value) { promise.success($0) }
        return promise.future
    }

    public func asyncSaveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> Future<[VM]> {
        let promise = Promise<[VM]>()
        asyncSaveValues(values) { promise.success($0) }
        return promise.future
    }

    public func asyncSaveObject<O where O: NSCoding, O: Persistable>(object: O) -> Future<O> {
        let promise = Promise<O>()
        asyncSaveObject(object) { promise.success($0) }
        return promise.future
    }

    public func asyncSaveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> Future<OM> {
        let promise = Promise<OM>()
        asyncSaveObject(object) { promise.success($0) }
        return promise.future
    }
}

extension YapDatabaseConnection {

    public func asyncReplaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> Future<V> {
        let promise = Promise<V>()
        asyncReplaceValue(replacement) { promise.success($0) }
        return promise.future
    }

    public func asyncReplaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V]) -> Future<[V]> {
        let promise = Promise<[V]>()
        asyncReplaceValues(replacements) { promise.success($0) }
        return promise.future
    }

    public func asyncReplaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> Future<VM> {
        let promise = Promise<VM>()
        asyncReplaceValue(replacement) { promise.success($0) }
        return promise.future
    }

    public func asyncReplaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> Future<[VM]> {
        let promise = Promise<[VM]>()
        asyncReplaceValues(replacements) { promise.success($0) }
        return promise.future
    }
}

