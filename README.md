![](https://raw.githubusercontent.com/danthorpe/YapDatabaseExtensions/development/header.png)

[![Build status](https://badge.buildkite.com/95784c169af7db5e36cefe146d5d3f3899c8339d46096a6349.svg)](https://buildkite.com/danthorpe/yapdatabaseextensions?branch=development)
[![Coverage Status](https://coveralls.io/repos/github/danthorpe/YapDatabaseExtensions/badge.svg?branch=development)](https://coveralls.io/github/danthorpe/YapDatabaseExtensions?branch=development)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/YapDatabaseExtensions.svg)](https://img.shields.io/cocoapods/v/YapDatabaseExtensions.svg)
[![CocoaPods Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/YapDatabaseExtensions.svg?style=flat)](https://cocoapods.org/pods/YapDatabaseExtensions)
[![Platform](https://img.shields.io/cocoapods/p/YapDatabaseExtensions.svg?style=flat)](http://cocoadocs.org/docsets/YapDatabaseExtensions)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# YapDatabaseExtensions

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
}
``` 

The `identifier` property allows the type to support an identifier type such as `NSUUID` or `Int`.

While not a requirement of YapDatabase, for these extensions, it is required that values of the same type are stored in the same collection - it is a static property.

There is also a `YapDB.Index` struct which composes the key and collection into a single type. This is used internally for all access methods. Properties defined in an extension on `Persistable` provide access to `key` and `index`.

### Metadata
YapDatabase supports storing metadata alongside the primary object. YapDatabaseExtensions supports optional reading and writing of metadata alongside a `Persistable` type.

Your custom metadata types must conform to either `NSCoding` or `ValueCoding`.

In this version of YapDatabaseExtensions, metadata has been removed from `Persistable`, and all reads and writes of metadata must be done explicitly. Additionally, since the `MetadataType` is decoupled from the `Persistable` type, a single `Persistable` type can use many different types of metadata, as appropriate. When you want to read or write a value and it's metadata together, you use the "withMetadata" variants of the API, which accept and return `YapItem<Value, Metadata>` values. `YapItem` is basically a slightly nicer wrapper than a Swift tuple, which can be extended, unlike anonymous tuple types.

## “Correct” Type Patterns
Because the generic protocols, `ValueCoding` and `CodingType` have self-reflective properties, they must be correctly implemented for the APIs to be available. This means that the equality `ValueCoding.Coder.ValueType == Self` must be met. The APIs are all composed with this represented in their generic where clauses. This means that if your `ValueCoding` type is not the `ValueType` of its `Coder`, your code will not compile.

Therefore, there are six valid `Persistable` type patterns as described in the table below:

Item encoding | Metadata encoding | Pattern
--------------|-------------------|------------------
`NSCoding`    | No Metadata       | Object
`NSCoding`    | `NSCoding`        | ObjectWithObjectMetadata
`NSCoding`    | `ValueCoding`     | ObjectWithValueMetadata
`ValueCoding` | No Metadata       | Value
`ValueCoding` | `NSCoding`        | ValueWithObjectMetadata
`ValueCoding` | `ValueCoding`     | ValueWithValueMetadata

## Extension APIs

YapDatabaseExtensions provides two styles of API. The *functional* API works on `YapDatabase` types, `YapDatabaseReadTransaction`, `YapDatabaseReadWriteTransaction` and `YapDatabaseConnection`. The *persistable* API works on your `Persistable` types directly, and receives the `YapDatabase` type as arguments.

### Functional API

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

if let meta: MetadataType? = connection.readMetadataAtIndex(index) {
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
    let meta: [MetadataType] = transaction.readMetadataAtIndexes(indexes)
}
```

### `Persistable` API

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
if let item = Item.read(transaction).atIndex(index) {
   // etc - item is correct type, no casting required.
}

// Read value and metadata using a YapDB.Index.
if let item: YapItem<Item, MetadataType>? = Item.read(transaction).withMetadataAtIndex(index) {
   // etc - item is a correct type, no casting required.
   // item.value contains the value
   // item.metadata contains the metadata, wrapped in an Optional
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
if let item = Item.read(connection).atIndex(index) {
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

## Developing

To start working in this repository’s `YapDatabaseExtensions.xcodeproj`, you’ll need to use [Carthage](https://github.com/Carthage/Carthage#installing-carthage) to download & build the project’s dependencies, with the commands `carthage checkout` and `carthage build`.

## Author

Daniel Thorpe, [@danthorpe](https://twitter.com/danthorpe)
Jim Roepcke, [@JimRoepcke](https://twitter.com/JimRoepcke)

## License

YapDatabaseExtensions is available under the MIT license. See the LICENSE file for more info.
