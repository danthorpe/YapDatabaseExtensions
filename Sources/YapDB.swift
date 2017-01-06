//
//  Created by Daniel Thorpe on 22/04/2015.
//

import YapDatabase
import YapDatabase.YapDatabaseView
import YapDatabase.YapDatabaseFilteredView
import YapDatabase.YapDatabaseFullTextSearch
import YapDatabase.YapDatabaseSecondaryIndex

protocol YapDatabaseViewProducer {
    func createDatabaseView() -> YapDatabaseView
}

protocol YapDatabaseExtensionRegistrar {
    func isRegisteredInDatabase(_ database: YapDatabase) -> Bool
    func registerInDatabase(_ database: YapDatabase, withConnection: YapDatabaseConnection?)
}

extension YapDB {

    /**
    A Swift enum wraps YapDatabaseView wrappers. It can be thought of being a Fetch
    Request type, as it defines what will be fetched out of the database. The Fetch
    instance should be used by injecting it into a FetchConfiguration.
    */
    public enum Fetch: YapDatabaseExtensionRegistrar {

        case view(YapDB.View)
        case filter(YapDB.Filter)
        case search(YapDB.SearchResults)
        case index(YapDB.SecondaryIndex)

        public var name: String {
            switch self {
            case let .view(view):       return view.name
            case let .filter(filter):   return filter.name
            case let .search(search):   return search.name
            case let .index(index):     return index.name
            }
        }

        var registrar: YapDatabaseExtensionRegistrar {
            switch self {
            case let .view(view):       return view
            case let .filter(filter):   return filter
            case let .search(search):   return search
            case let .index(index):     return index
            }
        }

        /**
        Utility function which can check if the extension is already registed in YapDatabase.
        
        - parameter database: a YapDatabase instance
        - returns: a Bool
        */
        public func isRegisteredInDatabase(_ database: YapDatabase) -> Bool {
            return registrar.isRegisteredInDatabase(database)
        }

        /**
        Utility function can register the extensions in YapDatabase, optionally using the supplied connection.

        - parameter database: a YapDatabase instance
        - parameter connection: an optional YapDatabaseConnection, defaults to .None
        */
        public func registerInDatabase(_ database: YapDatabase, withConnection connection: YapDatabaseConnection? = .none) {
            registrar.registerInDatabase(database, withConnection: connection)
        }

        /**
        Creates the YapDatabaseViewMappings object. Ensures that any database extensions are registered before returning.

        - parameter database: a YapDatabase instance
        - parameter connection: an optional YapDatabaseConnection, defaults to .None
        */
        public func createViewMappings(_ mappings: Mappings, inDatabase database: YapDatabase, withConnection connection: YapDatabaseConnection? = .none) -> YapDatabaseViewMappings {
            registerInDatabase(database, withConnection: connection)
            return mappings.createMappingsWithViewName(name)
        }
    }
}

extension YapDB {

    open class BaseExtension {
        let name: String
        let version: String
        let collections: Set<String>?
        let persistent: Bool

        init(name n: String, version v: String = "1.0", persistent p: Bool = true, collections c: [String]? = .none) {
            name = n
            version = v
            persistent = p
            collections = c.map { Set($0) }
        }

        /**
        Utility function which can check if the extension is already registed in YapDatabase.

        - parameter database: a YapDatabase instance
        - returns: A Bool
        */
        public func isRegisteredInDatabase(_ database: YapDatabase) -> Bool {
            return (database.registeredExtension(name) as? YapDatabaseExtension) != .none
        }
    }

    /**
    The base class for other YapDatabaseView wrapper types.
    */
    open class BaseView: BaseExtension {

        var options: YapDatabaseViewOptions {
            get {
                let options = YapDatabaseViewOptions()
                options.isPersistent = persistent
                options.allowedCollections = collections.map { YapWhitelistBlacklist(whitelist: $0) }
                return options
            }
        }
    }
}

extension YapDB {

    /**
    A wrapper around YapDatabaseView. It can be constructed with a name, which is
    the name the extension is registered under, a grouping enum type and a sorting enum type.
    */
    open class View: BaseView, YapDatabaseViewProducer, YapDatabaseExtensionRegistrar {

        /**
        An enum to make creating YapDatabaseViewGrouping easier. E.g.
        
            let grouping: YapDB.View.Grouping = .ByKey({ (collection, key) -> String! in
                // return a group or nil to exclude from the view.
            })

        */
        public enum Grouping {
            case byKey(YapDatabaseViewGroupingWithKeyBlock)
            case byObject(YapDatabaseViewGroupingWithObjectBlock)
            case byMetadata(YapDatabaseViewGroupingWithMetadataBlock)
            case byRow(YapDatabaseViewGroupingWithRowBlock)

            func object(withOptions opts: YapDatabaseBlockInvoke? = .none) -> YapDatabaseViewGrouping {
                if let opts = opts {
                    switch self {
                    case let .byKey(block):         return YapDatabaseViewGrouping.withOptions(opts, keyBlock: block)
                    case let .byObject(block):      return YapDatabaseViewGrouping.withOptions(opts, objectBlock: block)
                    case let .byMetadata(block):    return YapDatabaseViewGrouping.withOptions(opts, metadataBlock: block)
                    case let .byRow(block):         return YapDatabaseViewGrouping.withOptions(opts, rowBlock: block)
                    }
                } else {
                    switch self {
                    case let .byKey(block):         return YapDatabaseViewGrouping.withKeyBlock(block)
                    case let .byObject(block):      return YapDatabaseViewGrouping.withObjectBlock(block)
                    case let .byMetadata(block):    return YapDatabaseViewGrouping.withMetadataBlock(block)
                    case let .byRow(block):         return YapDatabaseViewGrouping.withRowBlock(block)
                    }
                }
            }
        }

        /**
        An enum to make creating YapDatabaseViewSorting easier.
        */
        public enum Sorting {
            case byKey(YapDatabaseViewSortingWithKeyBlock)
            case byObject(YapDatabaseViewSortingWithObjectBlock)
            case byMetadata(YapDatabaseViewSortingWithMetadataBlock)
            case byRow(YapDatabaseViewSortingWithRowBlock)

            func object(withOptions opts: YapDatabaseBlockInvoke? = .none) -> YapDatabaseViewSorting {
                if let opts = opts {
                    switch self {
                    case let .byKey(block):         return YapDatabaseViewSorting.withOptions(opts, keyBlock: block)
                    case let .byObject(block):      return YapDatabaseViewSorting.withOptions(opts, objectBlock: block)
                    case let .byMetadata(block):    return YapDatabaseViewSorting.withOptions(opts, metadataBlock: block)
                    case let .byRow(block):         return YapDatabaseViewSorting.withOptions(opts, rowBlock: block)
                    }
                } else {
                    switch self {
                    case let .byKey(block):         return YapDatabaseViewSorting.withKeyBlock(block)
                    case let .byObject(block):      return YapDatabaseViewSorting.withObjectBlock(block)
                    case let .byMetadata(block):    return YapDatabaseViewSorting.withMetadataBlock(block)
                    case let .byRow(block):         return YapDatabaseViewSorting.withRowBlock(block)
                    }
                }
            }
        }

        let grouping: Grouping
        let groupingOptions: YapDatabaseBlockInvoke?
        let sorting: Sorting
        let sortingOptions: YapDatabaseBlockInvoke?

        /**
        Initializer for a View. 
        
        - parameter name: a String, the name of the extension
        - parameter grouping: a Grouping instance - how should the view group the database items?
        - parameter sorting: a Sorting instance - inside each group, how should the view sort the items?
        - parameter version: a String, defaults to "1.0"
        - parameter persistent: a Bool, defaults to true - meaning that the contents of the view will be stored in YapDatabase between launches.
        - parameter collections: an optional array of collections which is used to white list the collections searched when populating the view.
        */
        public init(name: String,
                    grouping g: Grouping, groupingOptions go: YapDatabaseBlockInvoke? = .none,
                             sorting s: Sorting, sortingOptions so: YapDatabaseBlockInvoke? = .none,
                            version: String = "1.0", persistent: Bool = true, collections: [String]? = .none) {
            grouping = g
            groupingOptions = go
            sorting = s
            sortingOptions = so
            super.init(name: name, version: version, persistent: persistent, collections: collections)
        }

        func createDatabaseView() -> YapDatabaseView {
            return YapDatabaseView(grouping: grouping.object(withOptions: groupingOptions), sorting: sorting.object(withOptions: sortingOptions), versionTag: version, options: options)
        }

        func registerInDatabase(_ database: YapDatabase, withConnection connection: YapDatabaseConnection? = .none) {
            if !isRegisteredInDatabase(database) {
                if let connection = connection {
                    database.register(createDatabaseView(), withName: name, connection: connection)
                }
                else {
                    database.register(createDatabaseView(), withName: name)
                }
            }
        }
    }
}

extension YapDB {

    /**
    A wrapper around YapDatabaseFilteredView. 
    
    A FilteredView is a view extension which consists of
    a parent view extension and a filtering block. In this case, the parent
    is a YapDB.Fetch type. This allows for filtering of other filters, and 
    even filtering of search results.
    */
    open class Filter: BaseView, YapDatabaseViewProducer, YapDatabaseExtensionRegistrar {

        /**
        An enum to make creating YapDatabaseViewFiltering easier.
        */
        public enum Filtering {
            case byKey(YapDatabaseViewFilteringWithKeyBlock)
            case byObject(YapDatabaseViewFilteringWithObjectBlock)
            case byMetadata(YapDatabaseViewFilteringWithMetadataBlock)
            case byRow(YapDatabaseViewFilteringWithRowBlock)

            func object(withOptions ops: YapDatabaseBlockInvoke? = .none) -> YapDatabaseViewFiltering {
                if let ops = ops {
                    switch self {
                    case .byKey(let block):      return YapDatabaseViewFiltering.withOptions(ops, keyBlock: block)
                    case .byObject(let block):   return YapDatabaseViewFiltering.withOptions(ops, objectBlock: block)
                    case .byMetadata(let block): return YapDatabaseViewFiltering.withOptions(ops, metadataBlock: block)
                    case .byRow(let block):      return YapDatabaseViewFiltering.withOptions(ops, rowBlock: block)
                    }
                } else {
                    switch self {
                    case .byKey(let block):      return YapDatabaseViewFiltering.withKeyBlock(block)
                    case .byObject(let block):   return YapDatabaseViewFiltering.withObjectBlock(block)
                    case .byMetadata(let block): return YapDatabaseViewFiltering.withMetadataBlock(block)
                    case .byRow(let block):      return YapDatabaseViewFiltering.withRowBlock(block)
                    }
                }
            }
        }

        let parent: YapDB.Fetch
        let filtering: Filtering
        let filteringOptions: YapDatabaseBlockInvoke?

        /**
        Initializer for a Filter
        
        - parameter name: a String, the name of the extension
        - parameter parent: a YapDB.Fetch instance, the parent extensions which will be filtered.
        - parameter filtering: a Filtering, simple filtering of each item in the parent view.
        - parameter version: a String, defaults to "1.0"
        - parameter persistent: a Bool, defaults to true - meaning that the contents of the view will be stored in YapDatabase between launches.
        - parameter collections: an optional array of collections which is used to white list the collections searched when populating the view.
        */
        public init(name: String, parent p: YapDB.Fetch, filtering f: Filtering, filteringOptions fo: YapDatabaseBlockInvoke? = .none,
                    version: String = "1.0", persistent: Bool = true, collections: [String]? = .none) {
            parent = p
            filtering = f
            filteringOptions = fo
            super.init(name: name, version: version, persistent: persistent, collections: collections)
        }

        func createDatabaseView() -> YapDatabaseView {
            return YapDatabaseFilteredView(parentViewName: parent.name, filtering: filtering.object(withOptions: filteringOptions), versionTag: version, options: options)
        }

        func registerInDatabase(_ database: YapDatabase, withConnection connection: YapDatabaseConnection? = .none) {
            if !isRegisteredInDatabase(database) {
                parent.registerInDatabase(database, withConnection: connection)
                if let connection = connection {
                    database.register(createDatabaseView(), withName: name, connection: connection)
                }
                else {
                    database.register(createDatabaseView(), withName: name)
                }
            }
        }
    }
}

extension YapDB {

    /**
    A wrapper around YapDatabaseFullTextSearch. 
    
    A YapDatabaseFullTextSearch is a view extension which consists of
    a parent view extension, column names to query and a search handler.
    In this case, the parent is a YapDB.Fetch type. This
    allows for searching of other filters, and even searching inside search results.
    */
    open class SearchResults: BaseView, YapDatabaseViewProducer, YapDatabaseExtensionRegistrar {

        /**
        An enum to make creating YapDatabaseFullTextSearchHandler easier.
        */
        public enum Handler {
            case byKey(YapDatabaseFullTextSearchWithKeyBlock)
            case byObject(YapDatabaseFullTextSearchWithObjectBlock)
            case byMetadata(YapDatabaseFullTextSearchWithMetadataBlock)
            case byRow(YapDatabaseFullTextSearchWithRowBlock)

            public var object: YapDatabaseFullTextSearchHandler {
                switch self {
                case let .byKey(block):         return YapDatabaseFullTextSearchHandler.withKeyBlock(block)
                case let .byObject(block):      return YapDatabaseFullTextSearchHandler.withObjectBlock(block)
                case let .byMetadata(block):    return YapDatabaseFullTextSearchHandler.withMetadataBlock(block)
                case let .byRow(block):         return YapDatabaseFullTextSearchHandler.withRowBlock(block)
                }
            }
        }

        let parent: YapDB.Fetch
        let searchName: String
        let columnNames: [String]
        let handler: Handler

        /**
        Initializer for a Search

        - parameter name: a String, the name of the search results view extension
        - parameter parent: a YapDB.Fetch instance, the parent extensions which will be filtered.
        - parameter search: a String, this is the name of full text search handler extension
        - parameter columnNames: an array of String instances, the column names are the dictionary keys used by the handler.
        - parameter handler: a Handler instance.
        - parameter version: a String, defaults to "1.0"
        - parameter persistent: a Bool, defaults to true - meaning that the contents of the view will be stored in YapDatabase between launches.
        - parameter collections: an optional array of collections which is used to white list the collections searched when populating the view.
        */
        public init(name: String, parent p: YapDB.Fetch, search: String, columnNames cn: [String], handler h: Handler, version: String = "1.0", persistent: Bool = true, collections: [String]? = .none) {
            parent = p
            searchName = search
            columnNames = cn
            handler = h
            super.init(name: name, version: version, persistent: persistent, collections: collections)
        }

        func createDatabaseView() -> YapDatabaseView {
            return YapDatabaseSearchResultsView(fullTextSearchName: searchName, parentViewName: parent.name, versionTag: version, options: .none)
        }

        func registerInDatabase(_ database: YapDatabase, withConnection connection: YapDatabaseConnection? = .none) {

            if (database.registeredExtension(searchName) as? YapDatabaseFullTextSearch) == .none {
                let fullTextSearch = YapDatabaseFullTextSearch(columnNames: columnNames, options: nil, handler: handler.object, versionTag: version)
                if let connection = connection {
                    database.register(fullTextSearch, withName: searchName, connection: connection)
                }
                else {
                    database.register(fullTextSearch, withName: searchName)
                }
            }

            if !isRegisteredInDatabase(database) {
                parent.registerInDatabase(database, withConnection: connection)
                if let connection = connection {
                    database.register(createDatabaseView(), withName: name, connection: connection)
                }
                else {
                    database.register(createDatabaseView(), withName: name)
                }
            }
        }
    }
}


extension YapDB {

    /**
    A wrapper around YapDatabaseSecondaryIndex.

    A YapDatabaseSecondaryIndex is an extention (but not a view extension) which
    is similar to a full text search extension. It features a handler, which must
    be provided to update a dictionary used to index records.
    */
    open class SecondaryIndex: BaseExtension, YapDatabaseExtensionRegistrar {

        public enum Handler {
            case byKey(YapDatabaseSecondaryIndexWithKeyBlock)
            case byObject(YapDatabaseSecondaryIndexWithObjectBlock)
            case byMetadata(YapDatabaseSecondaryIndexWithMetadataBlock)
            case byRow(YapDatabaseSecondaryIndexWithRowBlock)

            public var object: YapDatabaseSecondaryIndexHandler {
                switch self {
                case let .byKey(block): return YapDatabaseSecondaryIndexHandler.withKeyBlock(block)
                case let .byObject(block): return YapDatabaseSecondaryIndexHandler.withObjectBlock(block)
                case let .byMetadata(block): return YapDatabaseSecondaryIndexHandler.withMetadataBlock(block)
                case let .byRow(block): return YapDatabaseSecondaryIndexHandler.withRowBlock(block)
                }
            }
        }

        let handler: Handler
        let columnTypes: [String: YapDatabaseSecondaryIndexType]

        var options: YapDatabaseSecondaryIndexOptions {
            get {
                let options = YapDatabaseSecondaryIndexOptions()
                options.allowedCollections = collections.map { YapWhitelistBlacklist(whitelist: $0) }
                return options
            }
        }

        public init(name n: String, handler h: Handler, columnTypes ct: [String: YapDatabaseSecondaryIndexType], version: String = "1.0", persistent: Bool = true, collections c: [String]?) {
            handler = h
            columnTypes = ct
            super.init(name: n, version: version, persistent: persistent, collections: c)
        }

        func setup() -> YapDatabaseSecondaryIndexSetup {
            let setup = YapDatabaseSecondaryIndexSetup()
            for (column, indexType) in columnTypes {
                setup.addColumn(column, with: indexType)
            }
            return setup
        }

        open func registerInDatabase(_ database: YapDatabase, withConnection connection: YapDatabaseConnection?) {
            if !isRegisteredInDatabase(database) {
                let secondaryIndex = YapDatabaseSecondaryIndex(setup: setup(), handler: handler.object, versionTag: version, options: options)
                if let connection = connection {
                    database.register(secondaryIndex, withName: name, connection: connection)
                }
                else {
                    database.register(secondaryIndex, withName: name)
                }
            }
        }
    }
}

extension YapDB {

    public struct Mappings {

        public enum Kind {
            case composed(YapDatabaseViewMappings)
            case groups([String])
            case dynamic((filter: YapDatabaseViewMappingGroupFilter, sorter: YapDatabaseViewMappingGroupSort))
        }

        public static var passThroughFilter: YapDatabaseViewMappingGroupFilter {
            return { (_, _) in true }
        }

        public static var caseInsensitiveGroupSort: YapDatabaseViewMappingGroupSort {
            return { (group1, group2, _) in group1.caseInsensitiveCompare(group2) }
        }

        let kind: Kind

        public init(filter f: @escaping YapDatabaseViewMappingGroupFilter = Mappings.passThroughFilter, sort s: @escaping YapDatabaseViewMappingGroupSort = Mappings.caseInsensitiveGroupSort) {
            kind = .dynamic((f, s))
        }

        public init(groups: [String]) {
            kind = .groups(groups)
        }

        public init(composed: YapDatabaseViewMappings) {
            kind = .composed(composed)
        }

        func createMappingsWithViewName(_ viewName: String) -> YapDatabaseViewMappings {
            switch kind {
            case .composed(let mappings):
                return mappings
            case .groups(let groups):
                return YapDatabaseViewMappings(groups: groups, view: viewName)
            case .dynamic(let (filter: filter, sorter: sorter)):
                return YapDatabaseViewMappings(groupFilterBlock: filter, sortBlock: sorter, view: viewName)
            }
        }
    }
}

extension YapDB {

    public struct FetchConfiguration {

        public typealias MappingsConfigurationBlock = (YapDatabaseViewMappings) -> Void

        let fetch: Fetch
        let mappings: Mappings
        let block: MappingsConfigurationBlock?

        public var name: String {
            return fetch.name
        }

        public init(fetch f: Fetch, mappings m: Mappings = Mappings(), block b: MappingsConfigurationBlock? = .none) {
            fetch = f
            mappings = m
            block = b
        }

        public init(view: YapDB.View) {
            self.init(fetch: .view(view))
        }

        public init(filter: YapDB.Filter) {
            self.init(fetch: .filter(filter))
        }

        public init(search: YapDB.SearchResults) {
            self.init(fetch: .search(search))
        }

        public func createMappingsRegisteredInDatabase(_ database: YapDatabase, withConnection connection: YapDatabaseConnection? = .none) -> YapDatabaseViewMappings {
            let databaseViewMappings = fetch.createViewMappings(mappings, inDatabase: database, withConnection: connection)
            block?(databaseViewMappings)
            return databaseViewMappings
        }
    }
}


extension YapDB {

    open class Search {
        public typealias Query = (_ searchTerm: String) -> String

        let database: YapDatabase
        let connection: YapDatabaseConnection
        let queues: [(String, YapDatabaseSearchQueue)]
        let query: Query

        public init(db: YapDatabase, views: [YapDB.Fetch], query q: @escaping Query) {
            database = db
            connection = db.newConnection()
            let _views = views.filter { fetch in
                switch fetch {
                case .index(_): return false
                default: return true
                }
            }
            queues = _views.map { view in
                view.registerInDatabase(db)
                return (view.name, YapDatabaseSearchQueue())
            }
            query = q
        }

        public convenience init(db: YapDatabase, view: YapDB.Fetch, query: @escaping Query) {
            self.init(db: db, views: [view], query: query)
        }

        open func usingTerm(_ term: String) {
            for (_, queue) in queues {
                queue.enqueueQuery(query(term))
            }
            connection.asyncReadWrite { [queues = self.queues] transaction in
                for (name, queue) in queues {
                    if let searchResultsViewTransaction = transaction.ext(name) as? YapDatabaseSearchResultsViewTransaction {
                        searchResultsViewTransaction.performSearch(with: queue)
                    }
                    else {
                        assertionFailure("Error: Attempting search using results view with name: \(name) which isn't a registered database extension.")
                    }
                }
            }
        }
    }
}

