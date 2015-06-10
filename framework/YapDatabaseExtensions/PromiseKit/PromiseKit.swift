//
//  Created by Daniel Thorpe on 08/04/2015.
//

import YapDatabase
import PromiseKit

extension YapDatabaseConnection {

    public func asyncRead<Object where Object: Persistable>(key: String) -> Promise<Object?> {
        return Promise { (fulfiller, _) in
            self.asyncRead({ $0.read(key) }, queue: dispatch_get_main_queue(), completion: fulfiller)
        }
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> Promise<Value?> {
        return Promise { (fulfiller, _) in
            self.asyncRead({ $0.read(key) }, queue: dispatch_get_main_queue(), completion: fulfiller)
        }
    }
}

extension YapDatabaseConnection {

    public func asyncRead<Object where Object: Persistable>(keys: [String]) -> Promise<[Object]> {
        return Promise { (fulfiller, _) in
            self.asyncRead({ $0.read(keys) }, queue: dispatch_get_main_queue(), completion: fulfiller)
        }
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> Promise<[Value]> {
        return Promise { (fulfiller, _) in
            self.asyncRead({ $0.read(keys) }, queue: dispatch_get_main_queue(), completion: fulfiller)
        }
    }
}

extension YapDatabaseConnection {

    /**
    Asynchonously writes a Persistable object conforming to NSCoding to the database using the connection.

    :param: object An Object.
    :return: a Promise Object.
    */
    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Promise<Object> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(object, completion: fulfiller)
        }
    }

    /**
    Asynchonously writes a Persistable object with metadata, both conforming to NSCoding to the database inside the read write transaction.

    :param: object An ObjectWithObjectMetadata.
    :return: a Future ObjectWithObjectMetadata.
    */
    public func asyncWrite<ObjectWithObjectMetadata where ObjectWithObjectMetadata: NSCoding, ObjectWithObjectMetadata: ObjectMetadataPersistable>(object: ObjectWithObjectMetadata) -> Promise<ObjectWithObjectMetadata> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(object, completion: fulfiller)
        }
    }

    /**
    Asynchonously writes a Persistable object, conforming to NSCoding, with metadata value type to the database inside the read write transaction.

    :param: object An ObjectWithValueMetadata.
    :return: a Future ObjectWithValueMetadata.
    */
    public func asyncWrite<ObjectWithValueMetadata where ObjectWithValueMetadata: NSCoding, ObjectWithValueMetadata: ValueMetadataPersistable>(object: ObjectWithValueMetadata) -> Promise<ObjectWithValueMetadata> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(object, completion: fulfiller)
        }
    }

    /**
    Asynchonously writes a Persistable value conforming to Saveable to the database inside the read write transaction.

    :param: value A Value.
    :return: a Promise Value.
    */
    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Promise<Value> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(value, completion: fulfiller)
        }
    }

    /**
    Asynchonously writes a Persistable value with a metadata value, both conforming to Saveable, to the database inside the read write transaction.

    :param: value A ValueWithValueMetadata.
    :return: a Promise Value.
    */
    public func asyncWrite<ValueWithValueMetadata where ValueWithValueMetadata: Saveable, ValueWithValueMetadata: ValueMetadataPersistable, ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata>(value: ValueWithValueMetadata) -> Promise<ValueWithValueMetadata> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(value, completion: fulfiller)
        }
    }

    /**
    Asynchonously writes a Persistable value, conforming to Saveable with a metadata object conforming to NSCoding, to the database inside the read write transaction.

    :param: value A ValueWithObjectMetadata.
    :return: a Promise Value.
    */
    public func asyncWrite<ValueWithObjectMetadata where ValueWithObjectMetadata: Saveable, ValueWithObjectMetadata: ObjectMetadataPersistable, ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(value: ValueWithObjectMetadata) -> Promise<ValueWithObjectMetadata> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(value, completion: fulfiller)
        }
    }
}

extension YapDatabaseConnection {

    /**
    Asynchonously writes Persistable objects conforming to NSCoding to the database using the connection.

    :param: objects A SequenceType of Object instances.
    :return: a Promise array of Object instances.
    */
    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> Promise<[Object]> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(objects, completion: fulfiller)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable object with metadata, both conforming to NSCoding to the database inside the read write transaction.

    :param: objects A SequenceType of ObjectWithObjectMetadata instances.
    :returns: a Promise array of ObjectWithObjectMetadata instances.
    */
    public func asyncWrite<Objects, ObjectWithObjectMetadata where Objects: SequenceType, Objects.Generator.Element == ObjectWithObjectMetadata, ObjectWithObjectMetadata: NSCoding, ObjectWithObjectMetadata: ObjectMetadataPersistable>(objects: Objects) -> Promise<[ObjectWithObjectMetadata]> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(objects, completion: fulfiller)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable object, conforming to NSCoding, with metadata value type to the database inside the read write transaction.

    :param: objects A SequenceType of ObjectWithValueMetadata instances.
    :returns: a Promise array of ObjectWithValueMetadata instances.
    */
    public func asyncWrite<Objects, ObjectWithValueMetadata where Objects: SequenceType, Objects.Generator.Element == ObjectWithValueMetadata, ObjectWithValueMetadata: NSCoding, ObjectWithValueMetadata: ValueMetadataPersistable>(objects: Objects) -> Promise<[ObjectWithValueMetadata]> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(objects, completion: fulfiller)
        }
    }

    /**
    Asynchonously writes Persistable values conforming to Saveable to the database using the connection.

    :param: values A SequenceType of Value instances.
    :return: a Promise array of Value instances.
    */
    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> Promise<[Value]> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(values, completion: fulfiller)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable value, conforming to Saveable with a metadata object conforming to NSCoding, to the database inside the read write transaction.

    :param: values A SequenceType of ValueWithObjectMetadata instances.
    :returns: a Promise array of ValueWithObjectMetadata instances.
    */
    public func asyncWrite<Values, ValueWithObjectMetadata where Values: SequenceType, Values.Generator.Element == ValueWithObjectMetadata, ValueWithObjectMetadata: Saveable, ValueWithObjectMetadata: ObjectMetadataPersistable, ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(values: Values) -> Promise<[ValueWithObjectMetadata]> {
        return Promise { (fulfiller, _) in
            self.asyncWrite(values, completion: fulfiller)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable value with a metadata value, both conforming to Saveable, to the database inside the read write transaction.

    :param: values A SequenceType of ValueWithValueMetadata instances.
    :returns: a Promise array of ValueWithValueMetadata instances.
    */
    public func asyncWrite<Values, ValueWithValueMetadata where Values: SequenceType, Values.Generator.Element == ValueWithValueMetadata, ValueWithValueMetadata: Saveable, ValueWithValueMetadata: ValueMetadataPersistable, ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata>(values: Values) -> Promise<[ValueWithValueMetadata]> {
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

    public func asyncRead<Object where Object: Persistable>(key: String) -> Promise<Object?> {
        return Promise { (fulfiller, _) in
            self.asyncRead(key, queue: dispatch_get_main_queue(), completion: fulfiller)
        }
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(key: String) -> Promise<Value?> {
        return Promise { (fulfiller, _) in
            self.asyncRead(key, queue: dispatch_get_main_queue(), completion: fulfiller)
        }
    }
}

extension YapDatabase {

    public func asyncRead<Object where Object: Persistable>(keys: [String]) -> Promise<[Object]> {
        return Promise { (fulfiller, _) in
            self.asyncRead(keys, queue: dispatch_get_main_queue(), completion: fulfiller)
        }
    }

    public func asyncRead<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(keys: [String]) -> Promise<[Value]> {
        return Promise { (fulfiller, _) in
            self.asyncRead(keys, queue: dispatch_get_main_queue(), completion: fulfiller)
        }
    }
}

extension YapDatabase {

    /**
    Asynchonously writes a Persistable object conforming to NSCoding to the database using a new connection.

    :param: object An Object.
    :return: a Promise Object.
    */
    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Promise<Object> {
        return newConnection().asyncWrite(object)
    }

    /**
    Asynchonously writes a Persistable object with metadata, both conforming to NSCoding to the database using a new connection.

    :param: object An ObjectWithObjectMetadata.
    :return: a Future ObjectWithObjectMetadata.
    */
    public func asyncWrite<ObjectWithObjectMetadata where ObjectWithObjectMetadata: NSCoding, ObjectWithObjectMetadata: ObjectMetadataPersistable>(object: ObjectWithObjectMetadata) -> Promise<ObjectWithObjectMetadata> {
        return newConnection().asyncWrite(object)
    }

    /**
    Asynchonously writes a Persistable object, conforming to NSCoding, with metadata value type to the database using a new connection.

    :param: object An ObjectWithValueMetadata.
    :return: a Future ObjectWithValueMetadata.
    */
    public func asyncWrite<ObjectWithValueMetadata where ObjectWithValueMetadata: NSCoding, ObjectWithValueMetadata: ValueMetadataPersistable>(object: ObjectWithValueMetadata) -> Promise<ObjectWithValueMetadata> {
        return newConnection().asyncWrite(object)
    }

    /**
    Asynchonously writes a Persistable value conforming to Saveable to the database using a new connection.

    :param: value A Value.
    :return: a Promise Value.
    */
    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Promise<Value> {
        return newConnection().asyncWrite(value)
    }

    /**
    Asynchonously writes a Persistable value, conforming to Saveable with a metadata object conforming to NSCoding, to the database using a new connection.

    :param: value A ValueWithObjectMetadata.
    :return: a Promise Value.
    */
    public func asyncWrite<ValueWithObjectMetadata where ValueWithObjectMetadata: Saveable, ValueWithObjectMetadata: ObjectMetadataPersistable, ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(value: ValueWithObjectMetadata) -> Promise<ValueWithObjectMetadata> {
        return newConnection().asyncWrite(value)
    }

    /**
    Asynchonously writes a Persistable value with a metadata value, both conforming to Saveable, to the database using a new connection.

    :param: value A ValueWithValueMetadata.
    :return: a Promise Value.
    */
    public func asyncWrite<ValueWithValueMetadata where ValueWithValueMetadata: Saveable, ValueWithValueMetadata: ValueMetadataPersistable, ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata>(value: ValueWithValueMetadata) -> Promise<ValueWithValueMetadata> {
        return newConnection().asyncWrite(value)
    }
}

extension YapDatabase {

    /**
    Asynchonously writes Persistable objects conforming to NSCoding to the database using a new connection.

    :param: objects A SequenceType of Object instances.
    :return: a Promise array of Object instances.
    */
    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> Promise<[Object]> {
        return newConnection().asyncWrite(objects)
    }

    /**
    Asynchonously writes a sequence of Persistable object with metadata, both conforming to NSCoding to the database using a new connection.

    :param: objects A SequenceType of ObjectWithObjectMetadata instances.
    :returns: a Promise array of ObjectWithObjectMetadata instances.
    */
    public func asyncWrite<Objects, ObjectWithObjectMetadata where Objects: SequenceType, Objects.Generator.Element == ObjectWithObjectMetadata, ObjectWithObjectMetadata: NSCoding, ObjectWithObjectMetadata: ObjectMetadataPersistable>(objects: Objects) -> Promise<[ObjectWithObjectMetadata]> {
        return newConnection().asyncWrite(objects)
    }

    /**
    Asynchonously writes a sequence of Persistable object, conforming to NSCoding, with metadata value type to the database using a new connection.

    :param: objects A SequenceType of ObjectWithValueMetadata instances.
    :returns: a Promise array of ObjectWithValueMetadata instances.
    */
    public func asyncWrite<Objects, ObjectWithValueMetadata where Objects: SequenceType, Objects.Generator.Element == ObjectWithValueMetadata, ObjectWithValueMetadata: NSCoding, ObjectWithValueMetadata: ValueMetadataPersistable>(objects: Objects) -> Promise<[ObjectWithValueMetadata]> {
        return newConnection().asyncWrite(objects)
    }

    /**
    Asynchonously writes Persistable values conforming to Saveable to the database using a new connection.

    :param: values A SequenceType of Value instances.
    :return: a Promise array of Value instances.
    */
    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> Promise<[Value]> {
        return newConnection().asyncWrite(values)
    }

    /**
    Asynchonously writes a sequence of Persistable value, conforming to Saveable with a metadata object conforming to NSCoding, to the database using a new connection.

    :param: values A SequenceType of ValueWithObjectMetadata instances.
    :returns: a Promise array of ValueWithObjectMetadata instances.
    */
    public func asyncWrite<Values, ValueWithObjectMetadata where Values: SequenceType, Values.Generator.Element == ValueWithObjectMetadata, ValueWithObjectMetadata: Saveable, ValueWithObjectMetadata: ObjectMetadataPersistable, ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(values: Values) -> Promise<[ValueWithObjectMetadata]> {
        return newConnection().asyncWrite(values)
    }

    /**
    Asynchonously writes a sequence of Persistable value with a metadata value, both conforming to Saveable, to the database using a new connection.

    :param: values A SequenceType of ValueWithValueMetadata instances.
    :returns: a Promise array of ValueWithValueMetadata instances.
    */
    public func asyncWrite<Values, ValueWithValueMetadata where Values: SequenceType, Values.Generator.Element == ValueWithValueMetadata, ValueWithValueMetadata: Saveable, ValueWithValueMetadata: ValueMetadataPersistable, ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata>(values: Values) -> Promise<[ValueWithValueMetadata]> {
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

