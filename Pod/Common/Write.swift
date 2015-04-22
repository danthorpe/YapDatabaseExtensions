//
//  Created by Daniel Thorpe on 22/04/2015.
//
//

import YapDatabase

// MARK: - YapDatabaseTransaction

extension YapDatabaseReadWriteTransaction {

    func writeAtIndex(index: YapDatabase.Index, object: AnyObject, metadata: AnyObject? = .None) {
        if let metadata: AnyObject = metadata {
            setObject(object, forKey: index.key, inCollection: index.collection, withMetadata: metadata)
        }
        else {
            setObject(object, forKey: index.key, inCollection: index.collection)
        }
    }
}

extension YapDatabaseReadWriteTransaction {

    /**
    Writes a Persistable object conforming to NSCoding to the database inside the read write transaction.
        
    :param: object An Object.
    :returns: The Object.
    */
    public func write<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Object {
        writeAtIndex(indexForPersistable(object), object: object)
        return object
    }

    /**
    Writes a Persistable object with metadata, both conforming to NSCoding to the database inside the read write transaction.
    
    :param: object An Object.
    :returns: The Object.
    */
    public func write<ObjectWithObjectMetadata where ObjectWithObjectMetadata: NSCoding, ObjectWithObjectMetadata: ObjectMetadataPersistable>(object: ObjectWithObjectMetadata) -> ObjectWithObjectMetadata {
        writeAtIndex(indexForPersistable(object), object: object, metadata: object.metadata)
        return object
    }

    /**
    Writes a Persistable object, conforming to NSCoding, with metadata value type to the database inside the read write transaction.
    
    :param: object An Object.
    :returns: The Object.
    */
    public func write<ObjectWithValueMetadata where ObjectWithValueMetadata: NSCoding, ObjectWithValueMetadata: ValueMetadataPersistable>(object: ObjectWithValueMetadata) -> ObjectWithValueMetadata {
        writeAtIndex(indexForPersistable(object), object: object, metadata: object.metadata.archive)
        return object
    }

    /**
    Writes a Persistable value, conforming to Saveable to the database inside the read write transaction.

    :param: value A Value.
    :returns: The Value.
    */
    public func write<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Value {
        writeAtIndex(indexForPersistable(value), object: value.archive)
        return value
    }

    /**
    Writes a Persistable value with a metadata value, both conforming to Saveable, to the database inside the read write transaction.

    :param: value A Value.
    :returns: The Value.
    */
    public func write<ValueWithValueMetadata where ValueWithValueMetadata: Saveable, ValueWithValueMetadata: ValueMetadataPersistable, ValueWithValueMetadata.ArchiverType.ValueType == ValueWithValueMetadata>(value: ValueWithValueMetadata) -> ValueWithValueMetadata {
        writeAtIndex(indexForPersistable(value), object: value.archive, metadata: value.metadata.archive)
        return value
    }

    /**
    Writes a Persistable value, conforming to Saveable with a metadata object conforming to NSCoding, to the database inside the read write transaction.

    :param: value A Value.
    :returns: The Value.
    */
    public func write<ValueWithObjectMetadata where ValueWithObjectMetadata: Saveable, ValueWithObjectMetadata: ObjectMetadataPersistable, ValueWithObjectMetadata.ArchiverType.ValueType == ValueWithObjectMetadata>(value: ValueWithObjectMetadata) -> ValueWithObjectMetadata {
        writeAtIndex(indexForPersistable(value), object: value.archive, metadata: value.metadata)
        return value
    }
}

extension YapDatabaseReadWriteTransaction {

    public func write<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> [Object] {
        return map(objects, write)
    }

    public func write<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> [Value] {
        return map(values, write)
    }
}

// MARK: - YapDatabaseConnection

extension YapDatabaseConnection {

    public func write<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Object {
        return write({ $0.write(object) })
    }

    public func write<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Value {
        return write({ $0.write(value) })
    }
}

extension YapDatabaseConnection {

    public func write<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> [Object] {
        return write({ $0.write(objects) })
    }

    public func write<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> [Value] {
        return write({ $0.write(values) })
    }
}

extension YapDatabaseConnection {

    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Object) -> Void) {
        asyncReadWriteWithBlock({ $0.write(object) }, completionQueue: queue) { completion(object) }
    }

    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Value) -> Void) {
        asyncReadWriteWithBlock({ $0.write(value) }, completionQueue: queue) { completion(value) }
    }
}

extension YapDatabaseConnection {

    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Object]) -> Void) {
        asyncReadWriteWithBlock({ $0.write(objects) }, completionQueue: queue) { completion(Array(objects)) }
    }

    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Value]) -> Void) {
        asyncReadWriteWithBlock({ $0.write(values) }, completionQueue: queue) { completion(Array(values)) }
    }
}

// MARK: - YapDatabase

extension YapDatabase {

    public func write<Object where Object: NSCoding, Object: Persistable>(object: Object) -> Object {
        return newConnection().write(object)
    }

    public func write<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value) -> Value {
        return newConnection().write(value)
    }
}

extension YapDatabase {

    public func write<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects) -> [Object] {
        return newConnection().write(objects)
    }

    public func write<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values) -> [Value] {
        return newConnection().write(values)
    }
}

extension YapDatabase {

    public func asyncWrite<Object where Object: NSCoding, Object: Persistable>(object: Object, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Object) -> Void) {
        newConnection().asyncWrite(object, queue: queue, completion: completion)
    }

    public func asyncWrite<Value where Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(value: Value, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: (Value) -> Void) {
        newConnection().asyncWrite(value, queue: queue, completion: completion)
    }
}

extension YapDatabase {

    public func asyncWrite<Objects, Object where Objects: SequenceType, Objects.Generator.Element == Object, Object: NSCoding, Object: Persistable>(objects: Objects, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Object]) -> Void) {
        newConnection().asyncWrite(objects, queue: queue, completion: completion)
    }

    public func asyncWrite<Values, Value where Values: SequenceType, Values.Generator.Element == Value, Value: Saveable, Value: Persistable, Value.ArchiverType.ValueType == Value>(values: Values, queue: dispatch_queue_t = dispatch_get_main_queue(), completion: ([Value]) -> Void) {
        newConnection().asyncWrite(values, queue: queue, completion: completion)
    }
}

