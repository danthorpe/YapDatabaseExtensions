//
//  Created by Daniel Thorpe on 08/04/2015.
//

import YapDatabase
import PromiseKit

extension YapDatabaseConnection {

    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Promise<Object> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(object, completion: fulfiller)
        }
    }

    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Promise<Value> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(value, completion: fulfiller)
        }
    }
}

extension YapDatabaseConnection {

    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> Promise<[Object]> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(objects, completion: fulfiller)
        }
    }

    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> Promise<[Value]> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(values, completion: fulfiller)
        }
    }
}

extension YapDatabaseConnection {

    public func asyncRemove<Item where Item: Persistable>(item: Item) -> Promise<Void> {
        return Promise { (fulfiller, _) in
            self.asyncRemove(item, completion: fulfiller)
        }
    }
}

extension YapDatabaseConnection {

    public func asyncRemove<Items where Items: SequenceType, Items.Generator.Element: Persistable>(items: Items) -> Promise<Void> {
        return Promise { (fulfiller, _) in
            self.asyncRemove(items, completion: fulfiller)
        }
    }
}



extension YapDatabase {

    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Promise<Object> {
        return newConnection().asyncWrite(object)
    }

    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Promise<Value> {
        return newConnection().asyncWrite(value)
    }
}

extension YapDatabase {

    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> Promise<[Object]> {
        return newConnection().asyncWrite(objects)
    }

    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> Promise<[Value]> {
        return newConnection().asyncWrite(values)
    }
}

extension YapDatabase {

    public func asyncRemove<Item where Item: Persistable>(item: Item) -> Promise<Void> {
        return newConnection().asyncRemove(item)
    }
}

extension YapDatabase {

    public func asyncRemove<Items where Items: SequenceType, Items.Generator.Element: Persistable>(items: Items) -> Promise<Void> {
        return newConnection().asyncRemove(items)
    }
}











//// MARK: - YapDatabase
//
//extension YapDatabase {
//
//    public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> Promise<V> {
//        let connection = newConnection()
//        return connection.asyncSaveValue(value)
//    }
//
//    public func asyncSaveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> Promise<[V]> {
//        let connection = newConnection()
//        return connection.asyncSaveValues(values)
//    }
//
//    public func asyncSaveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> Promise<VM> {
//        let connection = newConnection()
//        return connection.asyncSaveValue(value)
//    }
//
//    public func asyncSaveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> Promise<[VM]> {
//        let connection = newConnection()
//        return connection.asyncSaveValues(values)
//    }
//
//    public func asyncSaveObject<O where O: NSCoding, O: Persistable>(object: O) -> Promise<O> {
//        let connection = newConnection()
//        return connection.asyncSaveObject(object)
//    }
//
//    public func asyncSaveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> Promise<OM> {
//        let connection = newConnection()
//        return connection.asyncSaveObject(object)
//    }
//}
//
//extension YapDatabase {
//
//    public func asyncReplaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> Promise<V> {
//        let connection = newConnection()
//        return connection.asyncReplaceValue(replacement)
//    }
//
//    public func asyncReplaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V]) -> Promise<[V]> {
//        let connection = newConnection()
//        return connection.asyncReplaceValues(replacements)
//    }
//
//    public func asyncReplaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> Promise<VM> {
//        let connection = newConnection()
//        return connection.asyncReplaceValue(replacement)
//    }
//
//    public func asyncReplaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> Promise<[VM]> {
//        let connection = newConnection()
//        return connection.asyncReplaceValues(replacements)
//    }
//}
//
//// MARK: - YapDatabaseConnection
//
//extension YapDatabaseConnection {
//
//    public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> Promise<V> {
//        return Promise { (fulfiller, rejecter) in
//            self.asyncSaveValue(value) { value in fulfiller(value) }
//        }
//    }
//
//    public func asyncSaveValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(values: [V]) -> Promise<[V]> {
//        return Promise { (fulfiller, rejecter) in
//            self.asyncSaveValues(values) { values in fulfiller(values) }
//        }
//    }
//
//    public func asyncSaveValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(value: VM) -> Promise<VM> {
//        return Promise { (fulfiller, rejecter) in
//            self.asyncSaveValue(value) { value in fulfiller(value) }
//        }
//    }
//
//    public func asyncSaveValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(values: [VM]) -> Promise<[VM]> {
//        return Promise { (fulfiller, rejecter) in
//            self.asyncSaveValues(values) { values in fulfiller(values) }
//        }
//    }
//
//    public func asyncSaveObject<O where O: NSCoding, O: Persistable>(object: O) -> Promise<O> {
//        return Promise { (fulfiller, rejecter) in
//            self.asyncSaveObject(object) { object in fulfiller(object) }
//        }
//    }
//
//    public func asyncSaveObject<OM where OM: NSCoding, OM: ObjectMetadataPersistable>(object: OM) -> Promise<OM> {
//        return Promise { (fulfiller, rejecter) in
//            self.asyncSaveObject(object) { object in fulfiller(object) }
//        }
//    }
//}
//
//extension YapDatabaseConnection {
//
//    public func asyncReplaceValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacement: V) -> Promise<V> {
//        return Promise { (fulfiller, rejecter) in
//            self.asyncReplaceValue(replacement) { replacement in fulfiller(replacement) }
//        }
//    }
//
//    public func asyncReplaceValues<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(replacements: [V]) -> Promise<[V]> {
//        return Promise { (fulfiller, rejecter) in
//            self.asyncReplaceValues(replacements) { replacements in fulfiller(replacements) }
//        }
//    }
//
//    public func asyncReplaceValue<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacement: VM) -> Promise<VM> {
//        return Promise { (fulfiller, rejecter) in
//            self.asyncReplaceValue(replacement) { replacement in fulfiller(replacement) }
//        }
//    }
//
//    public func asyncReplaceValues<VM where VM: Saveable, VM: ValueMetadataPersistable, VM.ArchiverType.ValueType == VM>(replacements: [VM]) -> Promise<[VM]> {
//        return Promise { (fulfiller, rejecter) in
//            self.asyncReplaceValues(replacements) { replacements in fulfiller(replacements) }
//        }
//    }
//}

