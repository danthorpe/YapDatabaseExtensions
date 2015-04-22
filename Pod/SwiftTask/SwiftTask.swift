//
//  Created by Daniel Thorpe on 08/04/2015.
//

import YapDatabase
import SwiftTask


extension YapDatabaseConnection {

    public func asyncRead<Object where Object: Persistable>(key: String) -> Task<Void, Object?, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRead(key, completion: fulfill)
        }
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> Task<Void, Value?, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRead(key, completion: fulfill)
        }
    }
}

extension YapDatabaseConnection {

    public func asyncRead<Object where Object: Persistable>(keys: [String]) -> Task<Void, [Object], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRead(keys, completion: fulfill)
        }
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> Task<Void, [Value], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRead(keys, completion: fulfill)
        }
    }
}

extension YapDatabaseConnection {

    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Task<Void, Object, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(object, completion: fulfill)
        }
    }

    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Task<Void, Value, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(value, completion: fulfill)
        }
    }
}

extension YapDatabaseConnection {

    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> Task<Void, [Object], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(objects, completion: fulfill)
        }
    }

    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> Task<Void, [Value], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(values, completion: fulfill)
        }
    }
}

extension YapDatabaseConnection {

    public func asyncRemove<Item where Item: Persistable>(item: Item) -> Task<Void, Void, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRemove(item, completion: fulfill)
        }
    }
}

extension YapDatabaseConnection {

    public func asyncRemove<Items where Items: SequenceType, Items.Generator.Element: Persistable>(items: Items) -> Task<Void, Void, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRemove(items, completion: fulfill)
        }
    }
}


// MARK: - YapDatabase

extension YapDatabase {

    public func asyncRead<Object where Object: Persistable>(key: String) -> Task<Void, Object?, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRead(key, completion: fulfill)
        }
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> Task<Void, Value?, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRead(key, completion: fulfill)
        }
    }
}

extension YapDatabase {

    public func asyncRead<Object where Object: Persistable>(keys: [String]) -> Task<Void, [Object], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRead(keys, completion: fulfill)
        }
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> Task<Void, [Value], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRead(keys, completion: fulfill)
        }
    }
}


extension YapDatabase {

    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Task<Void, Object, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(object, completion: fulfill)
        }
    }

    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Task<Void, Value, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(value, completion: fulfill)
        }
    }
}

extension YapDatabase {

    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> Task<Void, [Object], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(objects, completion: fulfill)
        }
    }

    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> Task<Void, [Value], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(values, completion: fulfill)
        }
    }
}

extension YapDatabase {

    public func asyncRemove<Item where Item: Persistable>(item: Item) -> Task<Void, Void, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRemove(item, completion: fulfill)
        }
    }
}

extension YapDatabase {

    public func asyncRemove<Items where Items: SequenceType, Items.Generator.Element: Persistable>(items: Items) -> Task<Void, Void, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncRemove(items, completion: fulfill)
        }
    }
}






