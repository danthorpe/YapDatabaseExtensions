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

    /**
    Asynchonously writes a Persistable object conforming to NSCoding to the database using the connection.

    :param: object An Object.
    :return: a Task Object.
    */
    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Task<Void, Object, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(object, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a Persistable object with metadata, both conforming to NSCoding to the database inside the read write transaction.

    :param: object An ObjectWithObjectMetadata.
    :return: a Task ObjectWithObjectMetadata.
    */
    public func asyncWrite<ObjectWithObjectMetadata where ObjectWithObjectMetadata: NSCoding, ObjectWithObjectMetadata: ObjectMetadataPersistable>(object: ObjectWithObjectMetadata) -> Task<Void, ObjectWithObjectMetadata, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(object, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a Persistable object, conforming to NSCoding, with metadata value type to the database inside the read write transaction.

    :param: object An ObjectWithValueMetadata.
    :return: a Task ObjectWithValueMetadata.
    */
    public func asyncWrite<ObjectWithValueMetadata where ObjectWithValueMetadata: NSCoding, ObjectWithValueMetadata: ValueMetadataPersistable>(object: ObjectWithValueMetadata) -> Task<Void, ObjectWithValueMetadata, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(object, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a Persistable value conforming to Saveable to the database inside the read write transaction.

    :param: value A Value.
    :return: a Task Value.
    */
    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Task<Void, Value, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(value, completion: fulfill)
        }
    }


    /**
    Asynchonously writes a Persistable value, conforming to Saveable with a metadata object conforming to NSCoding, to the database inside the read write transaction.

    :param: value A ValueWithObjectMetadata.
    :return: a Task ValueWithObjectMetadata.
    */
    public func asyncWrite<ValueWithObjectMetadata where ValueWithObjectMetadata: Saveable, ValueWithObjectMetadata: ObjectMetadataPersistable, ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(value: ValueWithObjectMetadata) -> Task<Void, ValueWithObjectMetadata, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(value, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a Persistable value with a metadata value, both conforming to Saveable, to the database inside the read write transaction.

    :param: value A ValueWithValueMetadata.
    :return: a Task ValueWithValueMetadata.
    */
    public func asyncWrite<ValueWithValueMetadata where ValueWithValueMetadata: Saveable, ValueWithValueMetadata: ValueMetadataPersistable, ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata, ValueWithValueMetadata.MetadataType.ArchiverType.ValueType == ValueWithValueMetadata.MetadataType>(value: ValueWithValueMetadata) -> Task<Void, ValueWithValueMetadata, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(value, completion: fulfill)
        }
    }
}

extension YapDatabaseConnection {

    /**
    Asynchonously writes Persistable objects conforming to NSCoding to the database using the connection.

    :param: objects A SequenceType of Object instances.
    :return: a Task array of Object instances.
    */
    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> Task<Void, [Object], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(objects, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable object with metadata, both conforming to NSCoding to the database inside the read write transaction.

    :param: objects A SequenceType of ObjectWithObjectMetadata instances.
    :returns: a Task array of ObjectWithObjectMetadata instances.
    */
    public func asyncWrite<Objects, ObjectWithObjectMetadata where Objects: SequenceType, Objects.Generator.Element == ObjectWithObjectMetadata, ObjectWithObjectMetadata: NSCoding, ObjectWithObjectMetadata: ObjectMetadataPersistable>(objects: Objects) -> Task<Void, [ObjectWithObjectMetadata], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(objects, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable object, conforming to NSCoding, with metadata value type to the database inside the read write transaction.

    :param: objects A SequenceType of ObjectWithValueMetadata instances.
    :returns: a Task array of ObjectWithValueMetadata instances.
    */
    public func asyncWrite<Objects, ObjectWithValueMetadata where Objects: SequenceType, Objects.Generator.Element == ObjectWithValueMetadata, ObjectWithValueMetadata: NSCoding, ObjectWithValueMetadata: ValueMetadataPersistable>(objects: Objects) -> Task<Void, [ObjectWithValueMetadata], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(objects, completion: fulfill)
        }
    }

    /**
    Asynchonously writes Persistable values conforming to Saveable to the database using the connection.

    :param: values A SequenceType of Value instances.
    :return: a Task array of Value instances.
    */
    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> Task<Void, [Value], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(values, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable value, conforming to Saveable with a metadata object conforming to NSCoding, to the database inside the read write transaction.

    :param: values A SequenceType of ValueWithObjectMetadata instances.
    :returns: a Task array of ValueWithObjectMetadata instances.
    */
    public func asyncWrite<Values, ValueWithObjectMetadata where Values: SequenceType, Values.Generator.Element == ValueWithObjectMetadata, ValueWithObjectMetadata: Saveable, ValueWithObjectMetadata: ObjectMetadataPersistable, ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(values: Values) -> Task<Void, [ValueWithObjectMetadata], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(values, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable value with a metadata value, both conforming to Saveable, to the database inside the read write transaction.

    :param: values A SequenceType of ValueWithValueMetadata instances.
    :returns: a Task array of ValueWithValueMetadata instances.
    */
    public func asyncWrite<Values, ValueWithValueMetadata where Values: SequenceType, Values.Generator.Element == ValueWithValueMetadata, ValueWithValueMetadata: Saveable, ValueWithValueMetadata: ValueMetadataPersistable, ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata>(values: Values) -> Task<Void, [ValueWithValueMetadata], Void> {
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

    /**
    Asynchonously writes a Persistable object conforming to NSCoding to the database using a new connection.

    :param: object An Object.
    :return: a Task Object.
    */
    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Task<Void, Object, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(object, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a Persistable object with metadata, both conforming to NSCoding to the database using a new connection.

    :param: object An ObjectWithObjectMetadata.
    :return: a Task ObjectWithObjectMetadata.
    */
    public func asyncWrite<ObjectWithObjectMetadata where ObjectWithObjectMetadata: NSCoding, ObjectWithObjectMetadata: ObjectMetadataPersistable>(object: ObjectWithObjectMetadata) -> Task<Void, ObjectWithObjectMetadata, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(object, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a Persistable object, conforming to NSCoding, with metadata value type to the database using a new connection.

    :param: object An ObjectWithValueMetadata.
    :return: a Task ObjectWithValueMetadata.
    */
    public func asyncWrite<ObjectWithValueMetadata where ObjectWithValueMetadata: NSCoding, ObjectWithValueMetadata: ValueMetadataPersistable>(object: ObjectWithValueMetadata) -> Task<Void, ObjectWithValueMetadata, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(object, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a Persistable value conforming to Saveable to the database using a new connection.

    :param: value A Value.
    :return: a Task Value.
    */
    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Task<Void, Value, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(value, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a Persistable value, conforming to Saveable with a metadata object conforming to NSCoding, to the database using a new connection.

    :param: value A ValueWithObjectMetadata.
    :return: a Task ValueWithObjectMetadata.
    */
    public func asyncWrite<ValueWithObjectMetadata where ValueWithObjectMetadata: Saveable, ValueWithObjectMetadata: ObjectMetadataPersistable, ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(value: ValueWithObjectMetadata) -> Task<Void, ValueWithObjectMetadata, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(value, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a Persistable value with a metadata value, both conforming to Saveable, to the database using a new connection.

    :param: value A ValueWithValueMetadata.
    :return: a Task ValueWithValueMetadata.
    */
    public func asyncWrite<ValueWithValueMetadata where ValueWithValueMetadata: Saveable, ValueWithValueMetadata: ValueMetadataPersistable, ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata, ValueWithValueMetadata.MetadataType.ArchiverType.ValueType == ValueWithValueMetadata.MetadataType>(value: ValueWithValueMetadata) -> Task<Void, ValueWithValueMetadata, Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(value, completion: fulfill)
        }
    }
}

extension YapDatabase {

    /**
    Asynchonously writes Persistable objects conforming to NSCoding to the database using a new connection.

    :param: objects A SequenceType of Object instances.
    :return: a Task array of Object instances.
    */
    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> Task<Void, [Object], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(objects, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable object with metadata, both conforming to NSCoding to the database using a new connection.

    :param: objects A SequenceType of ObjectWithObjectMetadata instances.
    :returns: a Task array of ObjectWithObjectMetadata instances.
    */
    public func asyncWrite<Objects, ObjectWithObjectMetadata where Objects: SequenceType, Objects.Generator.Element == ObjectWithObjectMetadata, ObjectWithObjectMetadata: NSCoding, ObjectWithObjectMetadata: ObjectMetadataPersistable>(objects: Objects) -> Task<Void, [ObjectWithObjectMetadata], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(objects, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable object, conforming to NSCoding, with metadata value type to the database using a new connection.

    :param: objects A SequenceType of ObjectWithValueMetadata instances.
    :returns: a Task array of ObjectWithValueMetadata instances.
    */
    public func asyncWrite<Objects, ObjectWithValueMetadata where Objects: SequenceType, Objects.Generator.Element == ObjectWithValueMetadata, ObjectWithValueMetadata: NSCoding, ObjectWithValueMetadata: ValueMetadataPersistable>(objects: Objects) -> Task<Void, [ObjectWithValueMetadata], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(objects, completion: fulfill)
        }
    }

    /**
    Asynchonously writes Persistable values conforming to Saveable to the database using a new connection.

    :param: values A SequenceType of Value instances.
    :return: a Task array of Value instances.
    */
    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> Task<Void, [Value], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(values, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable value, conforming to Saveable with a metadata object conforming to NSCoding, to the database using a new connection.

    :param: values A SequenceType of ValueWithObjectMetadata instances.
    :returns: a Task array of ValueWithObjectMetadata instances.
    */
    public func asyncWrite<Values, ValueWithObjectMetadata where Values: SequenceType, Values.Generator.Element == ValueWithObjectMetadata, ValueWithObjectMetadata: Saveable, ValueWithObjectMetadata: ObjectMetadataPersistable, ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(values: Values) -> Task<Void, [ValueWithObjectMetadata], Void> {
        return Task { _, fulfill, _, _ in
            self.asyncWrite(values, completion: fulfill)
        }
    }

    /**
    Asynchonously writes a sequence of Persistable value with a metadata value, both conforming to Saveable, to the database using a new connection.

    :param: values A SequenceType of ValueWithValueMetadata instances.
    :returns: a Task array of ValueWithValueMetadata instances.
    */
    public func asyncWrite<Values, ValueWithValueMetadata where Values: SequenceType, Values.Generator.Element == ValueWithValueMetadata, ValueWithValueMetadata: Saveable, ValueWithValueMetadata: ValueMetadataPersistable, ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata>(values: Values) -> Task<Void, [ValueWithValueMetadata], Void> {
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






