# 1.1

1. [[YAP-7](https://github.com/danthorpe/YapDatabaseExtensions/pull/7)]: Support `SequenceType` in arguments where appropriate. This became a bit of a significant refactor.
    - [x] `read` by index(es), value(s), object(s)
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
1. [[YAP-10](https://github.com/danthorpe/YapDatabaseExtensions/pull/10)]: Adds this CHANGELOG


# 1.0
- [x] Persistable & Saveable protocols
- [x] Metadata protocols
- [x] YapDatabase.Index
- [x] Read value(s)
- [x] Read object(s)
- [x] Save value(s)
- [x] Save object
- [x] Remove value
