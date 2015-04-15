//
//  Created by Daniel Thorpe on 08/04/2015.
//

import YapDatabase
import PromiseKit

// MARK: - YapDatabase

extension YapDatabase {

    public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> Promise<V> {
        let connection = newConnection()
        return connection.asyncSaveValue(value)
    }

    public func asyncSaveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> Promise<[V]> {
        let connection = newConnection()
        return connection.asyncSaveValues(values)
    }

    public func asyncSaveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> Promise<VM> {
        let connection = newConnection()
        return connection.asyncSaveValue(value)
    }

    public func asyncSaveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> Promise<[VM]> {
        let connection = newConnection()
        return connection.asyncSaveValues(values)
    }

    public func asyncSaveObject<O where O: NSCoding, O: Persistable>(object: O) -> Promise<O> {
        let connection = newConnection()
        return connection.asyncSaveObject(object)
    }

    public func asyncSaveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> Promise<OM> {
        let connection = newConnection()
        return connection.asyncSaveObject(object)
    }
}

extension YapDatabase {

    public func asyncReplaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> Promise<V> {
        let connection = newConnection()
        return connection.asyncReplaceValue(replacement)
    }

    public func asyncReplaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V]) -> Promise<[V]> {
        let connection = newConnection()
        return connection.asyncReplaceValues(replacements)
    }

    public func asyncReplaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> Promise<VM> {
        let connection = newConnection()
        return connection.asyncReplaceValue(replacement)
    }

    public func asyncReplaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> Promise<[VM]> {
        let connection = newConnection()
        return connection.asyncReplaceValues(replacements)
    }
}

// MARK: - YapDatabaseConnection

extension YapDatabaseConnection {

    public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> Promise<V> {
        return Promise { (fulfiller, rejecter) in
            self.asyncSaveValue(value) { value in fulfiller(value) }
        }
    }

    public func asyncSaveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> Promise<[V]> {
        return Promise { (fulfiller, rejecter) in
            self.asyncSaveValues(values) { values in fulfiller(values) }
        }
    }

    public func asyncSaveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> Promise<VM> {
        return Promise { (fulfiller, rejecter) in
            self.asyncSaveValue(value) { value in fulfiller(value) }
        }
    }

    public func asyncSaveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> Promise<[VM]> {
        return Promise { (fulfiller, rejecter) in
            self.asyncSaveValues(values) { values in fulfiller(values) }
        }
    }

    public func asyncSaveObject<O where O: NSCoding, O: Persistable>(object: O) -> Promise<O> {
        return Promise { (fulfiller, rejecter) in
            self.asyncSaveObject(object) { object in fulfiller(object) }
        }
    }

    public func asyncSaveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> Promise<OM> {
        return Promise { (fulfiller, rejecter) in
            self.asyncSaveObject(object) { object in fulfiller(object) }
        }
    }
}

extension YapDatabaseConnection {

    public func asyncReplaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> Promise<V> {
        return Promise { (fulfiller, rejecter) in
            self.asyncReplaceValue(replacement) { replacement in fulfiller(replacement) }
        }
    }

    public func asyncReplaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V]) -> Promise<[V]> {
        return Promise { (fulfiller, rejecter) in
            self.asyncReplaceValues(replacements) { replacements in fulfiller(replacements) }
        }
    }

    public func asyncReplaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> Promise<VM> {
        return Promise { (fulfiller, rejecter) in
            self.asyncReplaceValue(replacement) { replacement in fulfiller(replacement) }
        }
    }

    public func asyncReplaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> Promise<[VM]> {
        return Promise { (fulfiller, rejecter) in
            self.asyncReplaceValues(replacements) { replacements in fulfiller(replacements) }
        }
    }
}

