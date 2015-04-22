//
//  Created by Daniel Thorpe on 08/04/2015.
//

import YapDatabase
import BrightFutures


extension YapDatabaseConnection {

    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Future<Object> {
        let promise = Promise<Object>()
        asyncWrite(object) { promise.success($0) }
        return promise.future
    }

    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Future<Value> {
        let promise = Promise<Value>()
        asyncWrite(value) { promise.success($0) }
        return promise.future
    }
}

extension YapDatabaseConnection {

    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> Future<[Object]> {
        let promise = Promise<[Object]>()
        asyncWrite(objects) { promise.success($0) }
        return promise.future
    }

    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> Future<[Value]> {
        let promise = Promise<[Value]>()
        asyncWrite(values) { promise.success($0) }
        return promise.future
    }
}

extension YapDatabaseConnection {

    public func asyncRemove<Item where Item: Persistable>(item: Item) -> Future<Void> {
        let promise = Promise<Void>()
        asyncRemove(item) { promise.success($0) }
        return promise.future
    }
}

extension YapDatabaseConnection {

    public func asyncRemove<Items where Items: SequenceType, Items.Generator.Element: Persistable>(items: Items) -> Future<Void> {
        let promise = Promise<Void>()
        asyncRemove(items) { promise.success($0) }
        return promise.future
    }
}


extension YapDatabase {

    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Future<Object> {
        let promise = Promise<Object>()
        asyncWrite(object) { promise.success($0) }
        return promise.future
    }

    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Future<Value> {
        let promise = Promise<Value>()
        asyncWrite(value) { promise.success($0) }
        return promise.future
    }
}

extension YapDatabase {

    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> Future<[Object]> {
        let promise = Promise<[Object]>()
        asyncWrite(objects) { promise.success($0) }
        return promise.future
    }

    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> Future<[Value]> {
        let promise = Promise<[Value]>()
        asyncWrite(values) { promise.success($0) }
        return promise.future
    }
}

extension YapDatabase {

    public func asyncRemove<Item where Item: Persistable>(item: Item) -> Future<Void> {
        let promise = Promise<Void>()
        asyncRemove(item) { promise.success($0) }
        return promise.future
    }
}

extension YapDatabase {

    public func asyncRemove<Items where Items: SequenceType, Items.Generator.Element: Persistable>(items: Items) -> Future<Void> {
        let promise = Promise<Void>()
        asyncRemove(items) { promise.success($0) }
        return promise.future
    }
}


