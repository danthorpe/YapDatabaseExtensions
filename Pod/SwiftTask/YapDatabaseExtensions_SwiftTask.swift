//
//  Created by Daniel Thorpe on 08/04/2015.
//

import YapDatabase
import SwiftTask

// MARK: - YapDatabase

extension YapDatabase {

    public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> Task<Void, V, Void> {
        return Task<Void, V, Void> { _, fulfill, _, _ in
            self.asyncSaveValue(value) { value in fulfill(value) }
        }
    }

    public func asyncSaveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> Task<Void, [V], Void> {
        return Task<Void, [V], Void> { _, fulfill, _, _ in
            self.asyncSaveValues(values) { value in fulfill(values) }
        }
    }

    public func asyncSaveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> Task<Void, VM, Void> {
        return Task<Void, VM, Void> { _, fulfill, _, _ in
            self.asyncSaveValue(value) { value in fulfill(value) }
        }
    }

    public func asyncSaveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> Task<Void, [VM], Void> {
        return Task<Void, [VM], Void> { _, fulfill, _, _ in
            self.asyncSaveValues(values) { value in fulfill(values) }
        }
    }

    public func asyncSaveObject<O where O: NSCoding, O: Persistable>(object: O) -> Task<Void, O, Void> {
        return Task<Void, O, Void> { _, fulfill, _, _ in
            self.asyncSaveObject(object) { object in fulfill(object) }
        }
    }

    public func asyncSaveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> Task<Void, OM, Void> {
        return Task<Void, OM, Void> { _, fulfill, _, _ in
            self.asyncSaveObject(object) { object in fulfill(object) }
        }
    }
}

extension YapDatabase {

    public func asyncReplaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> Task<Void, V, Void> {
        return Task<Void, V, Void> { _, fulfill, _, _ in
            self.asyncReplaceValue(replacement) { replacement in fulfill(replacement) }
        }
    }
}

// MARK: - YapDatabaseConnection

extension YapDatabaseConnection {

    public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> Task<Void, V, Void> {
        return Task<Void, V, Void> { _, fulfill, _, _ in
            self.asyncSaveValue(value) { value in fulfill(value) }
        }
    }

    public func asyncSaveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> Task<Void, [V], Void> {
        return Task<Void, [V], Void> { _, fulfill, _, _ in
            self.asyncSaveValues(values) { value in fulfill(values) }
        }
    }

    public func asyncSaveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> Task<Void, VM, Void> {
        return Task<Void, VM, Void> { _, fulfill, _, _ in
            self.asyncSaveValue(value) { value in fulfill(value) }
        }
    }

    public func asyncSaveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> Task<Void, [VM], Void> {
        return Task<Void, [VM], Void> { _, fulfill, _, _ in
            self.asyncSaveValues(values) { value in fulfill(values) }
        }
    }

    public func asyncSaveObject<O where O: NSCoding, O: Persistable>(object: O) -> Task<Void, O, Void> {
        return Task<Void, O, Void> { _, fulfill, _, _ in
            self.asyncSaveObject(object) { object in fulfill(object) }
        }
    }

    public func asyncSaveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> Task<Void, OM, Void> {
        return Task<Void, OM, Void> { _, fulfill, _, _ in
            self.asyncSaveObject(object) { object in fulfill(object) }
        }
    }
}

