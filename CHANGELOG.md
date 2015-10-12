# 2.1.3
1. [[YDB-54](https://github.com/danthorpe/YapDatabaseExtensions/pull/54)]: Fixes a bug where using a `writeBlockOperation` on a connection would execute the block inside an asynchronous transaction. This results in the `NSOperation` finishing before the block had completed, most likely leading to unexpected behavior.

# 2.1.2
1. [[YDB-53](https://github.com/danthorpe/YapDatabaseExtensions/pull/53)]: Fixes to some typos in the README - thanks Ryan (@aranasaurus)!
2. [[YDB-52](https://github.com/danthorpe/YapDatabaseExtensions/pull/52)]: Modifies the project structure to support a “Functional” API only via CocoaPods subspecs. See [Installation notes](https://github.com/danthorpe/YapDatabaseExtensions#installation).

# 2.1.1
1. [[YDB-50](https://github.com/danthorpe/YapDatabaseExtensions/pull/50)]: Breaks up the Read & Write files to reduce the number of lines. Adds a lot more documentation to functions - ~ 64% documentation coverage.

# 2.1.0
1. [[YDB-42](https://github.com/danthorpe/YapDatabaseExtensions/pull/42)]: Refactors read & write API, correctly supporting metadata.
2. [[YDB-43](https://github.com/danthorpe/YapDatabaseExtensions/pull/43)]: Makes project cross-platform (iOS & Mac OS)
3. [[YDB-44](https://github.com/danthorpe/YapDatabaseExtensions/pull/44)]: Enables code coverage reporting with CodeCov.io, see reports [here](https://codecov.io/github/danthorpe/YapDatabaseExtensions). 
4. [[YDB-45](https://github.com/danthorpe/YapDatabaseExtensions/pull/45)]: Adds back functional API.
5. [[YDB-47](https://github.com/danthorpe/YapDatabaseExtensions/pull/47)]: Updates README.
6. [[YDB-48](https://github.com/danthorpe/YapDatabaseExtensions/pull/48)]: Removes `Saveable`, created [ValueCoding](https://github.com/danthorpe/ValueCoding) as a standalone project and new dependency.

# 2.0.1
1. [[YDB-41](https://github.com/danthorpe/YapDatabaseExtensions/pull/41)]: Removes FRP extensions which don’t support Swift 2.0 yet.

# 2.0.0
1. [[YDB-38](https://github.com/danthorpe/YapDatabaseExtensions/pull/38)]: Preparations for Swift 2.0.

# 1.8.0
1. [[YDB-36](https://github.com/danthorpe/YapDatabaseExtensions/pull/36)]: Sets the required version of [BrightFutures](https://github.com/Thomvis/BrightFutures) to the latest for Swift 1.2, which is 2.0.1.
2. [[YDB-37](https://github.com/danthorpe/YapDatabaseExtensions/pull/37)]: Sets the required version of [PromiseKit](https://github.com/mxcl/PromiseKit) to the latest for Swift 1.2, which is 2.2.1 (as submitted to CocoaPods).

# 1.7.0
1. [[YDB-25](https://github.com/danthorpe/YapDatabaseExtensions/pull/25)]: Adds `YapDB.Search` to aid with running FTS queries. An example of using with will be forthcoming (probably after Swift 2.0 has settled). But essentially, you can initialize it with your db, an array of `YapDB.Fetch` values (which should be views) and a string mapper. Then execute `usingTerm(term: String)` with the search term supplied by the user to run the search.
2. [[YDB-26](https://github.com/danthorpe/YapDatabaseExtensions/pull/26)]: Adds some missing default parameters for the `YapDB.SecondaryIndex` wrapper.
3. [[YDB-27](https://github.com/danthorpe/YapDatabaseExtensions/pull/27)]: Removes an explicit unwrap which could cause a crash if pattern matching against value types.
4. [[YDB-29](https://github.com/danthorpe/YapDatabaseExtensions/pull/29)]: Adds support to `YapDatabaseConnection` for writeBlockOperation (`NSBlockOperation`), write and remove APIs. This is great if you want to perform a number of writes of different types in the same transaction inside of an `NSOperation` based architecture, as you can do:

```swift
queue.addOperation(connection.writeBlockOperation { transaction in 
	transaction.write(foo)
	transaction.write(bar)
	transaction.remove(bat)
})
```
If you're using my `Operations` framework, as these operations are `NSBlockOperation`s, use `ComposedOperation` to attach conditions or observers. E.g.

```swift
let write = ComposedOperation(connection.writeBlockOperation { transaction in 
	transaction.write(foo)
	transaction.write(bar)
	transaction.remove(bat)
})
write.addCondition(UserConfirmationCondition()) // etc etc
queue.addOperation(write)
```

5. [[YDB-30](https://github.com/danthorpe/YapDatabaseExtensions/pull/30)]: Expands the `YapDB.Mappings` type to support the full `YapDatabaseViewMappings` gamut.
6. [[YDB-31](https://github.com/danthorpe/YapDatabaseExtensions/pull/31)]: Silences a warning in the `removeAtIndexes` API.

# 1.6.0
1. [[YDB-22](https://github.com/danthorpe/YapDatabaseExtensions/pull/22)]: Adds `YapDB.Fetch.Index` which wraps `YapDatabaseSecondaryIndex` extension.
2. [[YDB-23](https://github.com/danthorpe/YapDatabaseExtensions/pull/23)]: Fixes a crash which has been observed in some cases in a Release configuration where writing a value type can fail to get the type’s Archiver.
3. [[YDB-24](https://github.com/danthorpe/YapDatabaseExtensions/pull/24)]: Just cleans up some of the code.


# 1.5.0

1. [[YDB-19](https://github.com/danthorpe/YapDatabaseExtensions/pull/19)]: Implements Saveable on YapDB.Index. This makes it easier to store references between YapDatabase objects. In general this is preferable to storing references as `let fooId: Foo.IdentifierType`.
2. [[YDB-21](https://github.com/danthorpe/YapDatabaseExtensions/pull/19)]: Restructures the project. The framework is now in an Xcode project in `framework`, with its associated unit tests in place. This is in preparation for Xcode 7, to get code coverage of the framework. The Example has been moved to `examples/iOS`, although it doesn’t really do much, except provide some models.

# 1.4.0

1. [[YDB-16](https://github.com/danthorpe/YapDatabaseExtensions/pull/16)]: Adds helper APIs for creating a YapDatabase. Includes a function for creating temporary database for use inside unit tests.

# 1.3.0

1. [[YDB-1](https://github.com/danthorpe/YapDatabaseExtensions/pull/1)]: Adds API for reading metadata, additionally fixes bugs where writing types with metadata would fail when using database or connections.
1. [[YDB-15](https://github.com/danthorpe/YapDatabaseExtensions/pull/15)]: Updates README documentation.

# 1.2.0

1. [[YDB-6](https://github.com/danthorpe/YapDatabaseExtensions/pull/6)]: Improves the code documentation significantly. Updates the README.
1. [[YDB-12](https://github.com/danthorpe/YapDatabaseExtensions/pull/12)]: Improves and adds to the test coverage. Fixes an oversight where keys and indexes were not uniqued before accessing the database.

# 1.1.1

1. [[YDB-11](https://github.com/danthorpe/YapDatabaseExtensions/pull/11)]: Renames `YapDatabase.Index` to `YapDB.Index`. 

# 1.1.0

1. [[YDB-7](https://github.com/danthorpe/YapDatabaseExtensions/pull/7)]: Support `SequenceType` in arguments where appropriate. This became a bit of a significant refactor.
    - [x] `read` at index(es), by key(s) for value(s), object(s)
    - [x] `readAll` #5 by Persistable
    - [x] `filterExisting` by value, object
    - [x] `write` by index, value(s), object(s)
    - [x] `remove` by index(es), Persistable(s))
    - [x] `asyncWrite` by index, value(s), object(s)
    	- [x] PromiseKit
    	- [x] BrightFutures
    	- [x] SwiftTask
    - [x] `asyncRemove` by index(es), Persistable(s))
    	- [x] PromiseKit
    	- [x] BrightFutures
    	- [x] SwiftTask
1. [[YDB-10](https://github.com/danthorpe/YapDatabaseExtensions/pull/10)]: Adds this CHANGELOG
1. [[YDB-3](https://github.com/danthorpe/YapDatabaseExtensions/pull/3)]: Adds async read API
    - [x] `asyncRead` at index(es)
    - [x] `asyncRead` by key(s) for value(s), object(s)
    	- [x] PromiseKit
    	- [x] BrightFutures
    	- [x] SwiftTask

# 1.0.0
- [x] Persistable & Saveable protocols
- [x] Metadata protocols
- [x] YapDatabase.Index
- [x] Read value(s)
- [x] Read object(s)
- [x] Save value(s)
- [x] Save object
- [x] Remove value
