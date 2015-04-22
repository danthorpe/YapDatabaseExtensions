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

