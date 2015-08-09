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
