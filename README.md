# YapDatabaseExtensions

[![Join the chat at https://gitter.im/danthorpe/YapDatabaseExtensions](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/danthorpe/YapDatabaseExtensions?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build status](https://badge.buildkite.com/95784c169af7db5e36cefe146d5d3f3899c8339d46096a6349.svg)](https://buildkite.com/danthorpe/yapdatabaseextensions)
[![codecov.io](http://codecov.io/github/danthorpe/YapDatabaseExtensions/coverage.svg?branch=development)](http://codecov.io/github/danthorpe/YapDatabaseExtensions?branch=development)
[![CocoaPods version](https://img.shields.io/cocoapods/v/YapDatabaseExtensions.svg)](https://cocoapods.org/pods/YapDatabaseExtensions) 
[![MIT License](https://img.shields.io/cocoapods/l/YapDatabaseExtensions.svg)](LICENSE) 
[![Platform iOS OS X](https://img.shields.io/cocoapods/p/YapDatabaseExtensions.svg)](PLATFORM)

Read my introductory blog post about [YapDatabase & YapDatabaseExtensions](http://danthorpe.me/posts/yap-database.html), and a follow up on [YapDatabaseExtensions 2](http://danthorpe.me/posts/yapdatabaseextensions-two--the-swiftening.html).

YapDatabaseExtensions is a suite of convenience APIs for working with [YapDatabase](https://github.com/yapstudios/YapDatabase). If you’re not familiar with YapDatabase, it’s a powerful key value database for iOS and Mac - [check it out](https://github.com/yapstudios/YapDatabase)!

## Motivation
While YapDatabase is great, it’s lacking some out of the box convenience and Swift support. In particular, YapDatabase works heavily with `AnyObject` types, which is fine for Objective-C but means no type fidelity with Swift. Similarly saving value types like structs or enums in YapDatabase is problematic. This framework has evolved through 2015 to tackle these issues.

## Value Types
The support for encoding and decoding value types, previously the `Saveable` and `Archiver` protocols, has been renamed and moved to their own project. [ValueCoding](https://github.com/danthorpe/ValueCoding) is a dependency of this framework (along with YapDatabase itself). See its [README](https://github.com/danthorpe/ValueCoding/blob/development/README.md) for more info. However, essentially, if you used this project before version 2.1, you’ll need to rename some types - and Xcode should present Fix It options. `Saveable` is now `ValueCoding`, its nested type, previously `ArchiverType` is now `Coder`, and this type must conform to a protocol, previously `Archiver`, now `CodingType`. See how they were all mixed up? Now fixed.

## `Persistable`
This protocol expresses what is required to support reading from and writing to YapDatabase. Objects are referenced inside the database with a key (a `String`) inside a collection (also a `String`).

```swift
public protocol Identifiable {
    typealias IdentifierType: CustomStringConvertible
    var identifier: IdentifierType { get }
}

public protocol Persistable: Identifiable {
    static var collection: String { get }
    var metadata: MetadataType? { get set }
}
``` 

The `identifier` property allows the type to support an identifier type such as `NSUUID` or `Int`.

While not a requirement of YapDatabase, for these extensions, it is required that values of the same type are stored in the same collection - it is a static property.

There is also a `YapDB.Index` struct which composes the key and collection into a single type. This is used internally for all access methods. Properties defined in an extension on `Persistable` provide access to `key` and `index`.

### Metadata
YapDatabase supports storing metadata alongside the primary object. YapDatabaseExtensions supports automatic reading and writing of metadata as an optional property of the `Persistable` type.

By default, all types which conform to `Persistable`, will get a `MetadataType` of `Void` which is synthesized by default. Therefore if you do not want or need a metadata type, there is nothing to do.

To support a custom metadata type, just add the following to your `Persistable` type, e.g.:

```swift
struct MyCustomValue: Persistable, ValueCoding {
    typealias Coder = MyCustomValueCoder
    static let collection = “MyCustomValues”
    var metadata: MyCustomMetadata? = .None
    let identifier: NSUUID
}
```

where the type (`MyCustomMetadata` in the above snippet) implements either `NSCoding` or `ValueCoding`.

When creating a new item, set the metadata property before saving the item to the database. YapDatabaseExtensions will then save the metadata inside YapDatabase correctly. *There is no need to encode the metadata inside the primary object*. When reading objects which have a valid `MetadataType`, YapDatabaseExtensions will automatically read, decode and set the item’s metadata before returning the item.

Note that previous metadata protocols `ObjectMetadataPersistable` and `ValueMetadataPersistable` have been deprecated in favor of `Persistable`.

## “Correct” Type Patterns
Because the generic protocols, `ValueCoding` and `CodingType` have self-reflective properties, they must be correctly implemented for the APIs to be available. This means that the equality `ValueCoding.Coder.ValueType == Self` must be met. The APIs are all composed with this represented in their generic where clauses. This means that if your `ValueCoding` type is not the `ValueType` of its `Coder`, your code will not compile.

Therefore, there are six valid `Persistable` type patterns as described in the table below:

Item encoding | Metadata encoding | Pattern
--------------|-------------------|------------------
`NSCoding`    | `Void` Metadata   | Object
`NSCoding`    | `NSCoding`        | ObjectWithObjectMetadata
`NSCoding`    | `ValueCoding`     | ObjectWithValueMetadata
`ValueCoding` | `Void` Metadata   | Value
`ValueCoding` | `NSCoding`        | ValueWithObjectMetadata
`ValueCoding` | `ValueCoding`     | ValueWithValueMetadata

There are also two styles of API. The *functional* API works on `YapDatabase` types, `YapDatabaseReadTransaction`, `YapDatabaseReadWriteTransaction` and `YapDatabaseConnection`. The *persistable* API works on your `Persistable` types directly, and receives the `YapDatabase` type as arguments.

## Functional API

The following “functional” APIs are available directly on the `YapDatabase` types.

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

For reading:

```swift
if let item: Item? = connection.readAtIndex(index) {
  // etc
}

if let meta: Item.MetadataType? = connection.readMetadataAtIndex(index) {
  // etc
}

let items: [Item] = connection.readAtIndexes(indexes)

if let item: Item? = connection.readByKey(index) {
  // etc
}

let items: [Item] = connection.readByKeys(keys)

let all: [Item] = connection.readAll()

connection.read { transaction in
    let a: Item? = transaction.readAtIndex(index)
    let b: Item? = transaction.readByKey(key)
    let c: [Item] = transaction.readAtIndexes(indexes)
    let d: [Item] = transaction.readByKeys(keys)
    let all: [Item] = transaction.readAll()
    let meta: [Item.MetadataType] = transaction.readMetadataAtIndexes(indexes)
}
```

## `Persistable` API

The APIs all work on single or sequences of `Persistable` items. To write to the database:

```swift
// Use a YapDatabaseReadWriteTransaction.
let written = item.write(transaction)

// Write synchronously using a YapDatabaseConnection.
let written = item.write(connection)

// Write asynchronously using a YapDatabaseConnection.
item.asyncWrite(connection) { written in
    print(“did finishing writing”)
}

// Return an NSOperation which will perform an sync write on a YapDatabaseConnection.
let write: NSOperation = item.write(connection)
``` 

Reading items from the database is a little different.

```swift
// Read using a YapDB.Index.
if let item = Item.read(transaction).byIndex(index) {
   // etc - item is correct type, no casting required.
}

// Read an array of items from an array of YapDB.Index(s)
let items = Item.read(transaction).atIndexes(indexes)

// Read using a key
if let item = Item.read(transaction).byKey(key) {
   // etc - item is correct type, no casting required.
}

// Read an array of items from an array of String(s)
let items = Item.read(transaction).byKeys(keys)

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

## Installation

YapDatabaseExtensions is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YapDatabaseExtensions'
```

If you don’t want the extensions API on `Persistable`, integrate the Functional subspec like this:

```ruby
pod 'YapDatabaseExtensions/Functional’
```

## API Documentation

API documentation is available on [CocoaDocs.org](http://cocoadocs.org/docsets/YapDatabaseExtensions).

## Author

Daniel Thorpe, [@danthorpe](https://twitter.com/danthorpe)

## License

YapDatabaseExtensions is available under the MIT license. See the LICENSE file for more info.
