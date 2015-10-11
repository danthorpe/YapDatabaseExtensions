# YapDatabaseExtensions

[![Join the chat at https://gitter.im/danthorpe/YapDatabaseExtensions](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/danthorpe/YapDatabaseExtensions?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build status](https://badge.buildkite.com/95784c169af7db5e36cefe146d5d3f3899c8339d46096a6349.svg)](https://buildkite.com/danthorpe/yapdatabaseextensions)
[![codecov.io](http://codecov.io/github/danthorpe/YapDatabaseExtensions/coverage.svg?branch=development)](http://codecov.io/github/danthorpe/YapDatabaseExtensions?branch=development)
[![CocoaPods version](https://img.shields.io/cocoapods/v/YapDatabaseExtensions.svg)](https://cocoapods.org/pods/YapDatabaseExtensions) 
[![MIT License](https://img.shields.io/cocoapods/l/YapDatabaseExtensions.svg)](LICENSE) 
[![Platform iOS OS X](https://img.shields.io/cocoapods/p/YapDatabaseExtensions.svg)](PLATFORM)

Read my introductory blog post about [YapDatabase & YapDatabaseExtensions](http://danthorpe.me/posts/yap-database.html).

YapDatabaseExtensions is a suite of convenience APIs for working with [YapDatabase](https://github.com/yapstudios/YapDatabase). If you’re not familiar with YapDatabase, it’s a powerful key value database for iOS and Mac - [check it out](https://github.com/yapstudios/YapDatabase)!

## Motivation
While YapDatabase is great, it’s lacking some out of the box convenience and Swift support. In particular, YapDatabase works heavily with `AnyObject` types, which is fine for Objective-C but means no type fidelity with Swift. Similarly saving value types like structs or enums in YapDatabase is problematic. This framework has evolved through 2015 to tackle these issues.

## Value Types
The support for encoding and decoding value types, previously the `Saveable` and `Archiver` protocols, has been renamed and moved to their own project. [ValueCoding](https://github.com/yapstudios/ValueCoding) is a dependency of this framework (along with YapDatabase itself). See its [README](https://github.com/danthorpe/ValueCoding/blob/development/README.md) for more info. However, essentially, if you used this project before version 2.1, you’ll need to rename some types - and Xcode should present Fix It options. `Saveable` is now `ValueCoding`, its nested type, previously `ArchiverType` is now `Coder`, and this type must conform to a protocol, previously `Archiver`, now `CodingType`. See how they were all mixed up? Now fixed.

## `Persistable`
These two protocols express what is required to support reading from and writing to YapDatabase. Objects are referenced inside the database with a key inside a collection. Both of these are `String` types, and `Persistable` defines the requirement.

```swift
public protocol Identifiable {
    typealias IdentifierType: CustomStringConvertible
    var identifier: IdentifierType { get }
}

public protocol Persistable: Identifiable {
    static var collection: String { get }
}
``` 

The `identifier` property allows the type to support an identifier type such as `NSUUID` or `Int`.

There is also a `YapDB.Index` struct which composes the key and collection in a single unit, and is used internally for all access methods. Properties defined in an extension on `Persistable` provide access to `key` and `index`.

## `MetadataPersistable`
YapDatabase support storing metadata alongside the primary object. `MetadataPersistable` is a generic protocol which supports the automatic reading and writing of metadata as a optional property of the `Persistable` type.

```swift
public protocol MetadataPersistable: Persistable {
    typealias MetadataType
    var metadata: MetadataType? { get set }
}
```

When creating a new item, set the metadata property before saving the item to the database. YapDatabaseExtensions will then save the metadata inside YapDatabase correctly. There is no need to encode the metadata inside the primary object. When reading objects which have a valid `MetadataType`, YapDatabaseExtensions will automatically read, decode and set an items metadata before returning it.

Note that previous metadata protocols `ObjectMetadataPersistable` and `ValueMetadataPersistable` have been deprecated.

## “Correct” Type Patterns
Because the generic protocols, `ValueCoding` and `CodingType` have self-reflective properties, they must be correctly implemented for the APIs to be available. This means that the equality `ValueCoding.Coder.ValueType == Self` is true. The APIs are all composed with this represented in their generic where clauses. This means that if your `ValueCoding` type is not the `ValueType` of its `Coder`, your code will probably not compile.

Therefore, there are six valid `Persistable` type patterns as described in the table below:

Item encoding | Metadata encoding | Pattern
——————————————|———————————————————|———————
`NSCoding`    | No Metadata       | Object
`NSCoding`    | `NSCoding`        | ObjectWithObjectMetadata
`NSCoding`    | `ValueCoding`     | ObjectWithValueMetadata
`ValueCoding` | No Metadata       | Value
`ValueCoding` | `NSCoding`        | ValueWithObjectMetadata
`ValueCoding` | `ValueCoding`     | ValueWithValueMetadata

There are also two styles of API. The *functional* API works on `YapDatabase` types, `YapDatabaseReadTransaction`, `YapDatabaseReadWriteTransaction` and `YapDatabaseConnection`. However, these read, write and remove methods are only available if your types is one of the four patterns with metadata. The *persistable* API works on your `Persistable` types, and is available for all six patterns.

## `Persistable` API

The APIs all work on single or sequences of `Persistable` items. To write to the database:

```swift
// Use a YapDatabaseReadWriteTransaction.
item.write.on(transaction)

// Write synchronously using a YapDatabaseConnection.
item.write.sync(connection)

// Write asynchronously using a YapDatabaseConnection.
item.write.async(connection) {
    print(“did finishing writing”)
}

// Return an NSOperation which will perform an async write on a YapDatabaseConnection.
let write = item.write.operation(connection)
``` 

Note that these write functions have no return values.

Reading items from the database is similar.

```swift
// Read using a YapDB.Index.
if let item = Item.read(transaction).byIndex(index) {
   // etc - item is correct type, no casting required.
}

// Read using a key
if let item = Item.read(transaction).byKey(key) {
   // etc - item is correct type, no casting required.
}

if let allItems = Item.read(transaction).all() {
   // etc - an array of Item types.
}

// Get the Items which exist for the given keys, and return the [String] keys which are missing.
let (items, missingKeys) = Item.read(transaction).filterExisting(someKeys)
``` 

Similarly, to work directly on a `YapDatabaseConnection`, use the following:

```swift
if let item = Item.read(connection).byIndex(index) {
   // etc - item is correct type, no casting required.
}

if let item = Item.read(connection).byKey(key) {
   // etc - item is correct type, no casting required.
}

if let allItems = Item.read(connection).all() {
   // etc - an array of Item types.
}

let (items, missingKeys) = Item.read(connection).filterExisting(someKeys)
```

## Functional API

For types which implement `MetadataPersistable` the following “functional” APIs are also available directly on the `YapDatabase` types.

```swift
// Get a YapDatabaseConnection
let connection = db.newConnection()

// Write a single item
connection.write(item) 

// Write an array of items, using one transaction.
connection.write(items)

// Write asynchronously
connection.asyncWrite(item) { print(“did finish writing”) }
connection.asyncWrite(items) { print(“did finish writing”) }

// Create a write transaction block for multiple writes.
connection.write { transaction in
    transaction.write(item)
    transaction.write(items) 
}

// Write many items asynchronously
connection.asyncWrite({ transaction in
    transaction.write(item)
    transaction.write(items) 
}, completion: { print(“did finish writing”) })
```

## Installation

YapDatabaseExtensions is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YapDatabaseExtensions'
```

## API Documentation

API documentation is available on [CocoaDocs.org](http://cocoadocs.org/docsets/YapDatabaseExtensions).

## Author

Daniel Thorpe, @danthorpe

## License

YapDatabaseExtensions is available under the MIT license. See the LICENSE file for more info.
