//
//  Created by Daniel Thorpe on 22/04/2015.
//

import YapDatabase

protocol YapDatabaseViewProducer {
    func createDatabaseView() -> YapDatabaseView
}

protocol YapDatabaseViewRegistrar {
    func isRegisteredInDatabase(database: YapDatabase) -> Bool
    func registerInDatabase(database: YapDatabase, withConnection: YapDatabaseConnection?)
}

extension YapDB {

    public enum Fetch: YapDatabaseViewRegistrar {

        case View(YapDB.View)
        case Filter(YapDB.Filter)
        case Search(YapDB.Search)

        public var name: String {
            switch self {
            case let .View(view):       return view.name
            case let .Filter(filter):   return filter.name
            case let .Search(search):   return search.name
            }
        }

        var registrar: YapDatabaseViewRegistrar {
            switch self {
            case let .View(view):       return view
            case let .Filter(filter):   return filter
            case let .Search(search):   return search
            }
        }

        public func isRegisteredInDatabase(database: YapDatabase) -> Bool {
            return registrar.isRegisteredInDatabase(database)
        }

        public func registerInDatabase(database: YapDatabase, withConnection connection: YapDatabaseConnection? = .None) {
            registrar.registerInDatabase(database, withConnection: connection)
        }

        func createViewMappings(mappings: Mappings, inDatabase database: YapDatabase, withConnection connection: YapDatabaseConnection? = .None) -> YapDatabaseViewMappings {
            registerInDatabase(database, withConnection: connection)
            return YapDatabaseViewMappings(groupFilterBlock: mappings.filter, sortBlock: mappings.sort, view: name)
        }
    }
}

extension YapDB {

    public class BaseView {
        let name: String
        let version: String
        let collections: Set<String>?
        let persistent: Bool

        var options: YapDatabaseViewOptions {
            get {
                let options = YapDatabaseViewOptions()
                options.isPersistent = persistent
                options.allowedCollections = collections.map { YapWhitelistBlacklist(whitelist: $0) }
                return options
            }
        }

        init(name n: String, version v: String = "1.0", persistent p: Bool = true, collections c: [String]? = .None) {
            name = n
            version = v
            persistent = p
            collections = c.map { Set($0) }
        }

        public func isRegisteredInDatabase(database: YapDatabase) -> Bool {
            return (database.registeredExtension(name) as? YapDatabaseView) != .None
        }
    }
}

extension YapDB {

    public class View: BaseView, YapDatabaseViewProducer, YapDatabaseViewRegistrar {

        public enum Grouping {
            case ByKey(YapDatabaseViewGroupingWithKeyBlock)
            case ByObject(YapDatabaseViewGroupingWithObjectBlock)
            case ByMetadata(YapDatabaseViewGroupingWithMetadataBlock)
            case ByRow(YapDatabaseViewGroupingWithRowBlock)

            public var object: YapDatabaseViewGrouping {
                switch self {
                case let .ByKey(block):         return YapDatabaseViewGrouping.withKeyBlock(block)
                case let .ByObject(block):      return YapDatabaseViewGrouping.withObjectBlock(block)
                case let .ByMetadata(block):    return YapDatabaseViewGrouping.withMetadataBlock(block)
                case let .ByRow(block):         return YapDatabaseViewGrouping.withRowBlock(block)
                }
            }
        }

        public enum Sorting {
            case ByKey(YapDatabaseViewSortingWithKeyBlock)
            case ByObject(YapDatabaseViewSortingWithObjectBlock)
            case ByMetadata(YapDatabaseViewSortingWithMetadataBlock)
            case ByRow(YapDatabaseViewSortingWithRowBlock)

            public var object: YapDatabaseViewSorting {
                switch self {
                case let .ByKey(block):         return YapDatabaseViewSorting.withKeyBlock(block)
                case let .ByObject(block):      return YapDatabaseViewSorting.withObjectBlock(block)
                case let .ByMetadata(block):    return YapDatabaseViewSorting.withMetadataBlock(block)
                case let .ByRow(block):         return YapDatabaseViewSorting.withRowBlock(block)
                }
            }
        }

        let grouping: Grouping
        let sorting: Sorting

        public init(name: String, grouping g: Grouping, sorting s: Sorting, version: String = "1.0", persistent: Bool = true, collections: [String]? = .None) {
            grouping = g
            sorting = s
            super.init(name: name, version: version, persistent: persistent, collections: collections)
        }

        func createDatabaseView() -> YapDatabaseView {
            return YapDatabaseView(grouping: grouping.object, sorting: sorting.object, versionTag: version, options: options)
        }

        func registerInDatabase(database: YapDatabase, withConnection connection: YapDatabaseConnection? = .None) {
            if !isRegisteredInDatabase(database) {
                if let connection = connection {
                    database.registerExtension(createDatabaseView(), withName: name, connection: connection)
                }
                else {
                    database.registerExtension(createDatabaseView(), withName: name)
                }
            }
        }
    }
}

extension YapDB {

    public class Filter: BaseView, YapDatabaseViewProducer, YapDatabaseViewRegistrar {

        public enum Filtering {
            case ByKey(YapDatabaseViewFilteringWithKeyBlock)
            case ByObject(YapDatabaseViewFilteringWithObjectBlock)
            case ByMetadata(YapDatabaseViewFilteringWithMetadataBlock)
            case ByRow(YapDatabaseViewFilteringWithRowBlock)

            public var object: YapDatabaseViewFiltering {
                switch self {
                case let .ByKey(block):         return YapDatabaseViewFiltering.withKeyBlock(block)
                case let .ByObject(block):      return YapDatabaseViewFiltering.withObjectBlock(block)
                case let .ByMetadata(block):    return YapDatabaseViewFiltering.withMetadataBlock(block)
                case let .ByRow(block):         return YapDatabaseViewFiltering.withRowBlock(block)
                }
            }
        }

        let parent: YapDB.Fetch
        let filtering: Filtering

        public init(name: String, parent p: YapDB.Fetch, filtering f: Filtering, version: String = "1.0", persistent: Bool = true, collections: [String]? = .None) {
            parent = p
            filtering = f
            super.init(name: name, version: version, persistent: persistent, collections: collections)
        }

        func createDatabaseView() -> YapDatabaseView {
            return YapDatabaseFilteredView(parentViewName: parent.name, filtering: filtering.object, versionTag: version, options: options)
        }

        func registerInDatabase(database: YapDatabase, withConnection connection: YapDatabaseConnection? = .None) {
            if !isRegisteredInDatabase(database) {
                parent.registerInDatabase(database, withConnection: connection)
                if let connection = connection {
                    database.registerExtension(createDatabaseView(), withName: name, connection: connection)
                }
                else {
                    database.registerExtension(createDatabaseView(), withName: name)
                }
            }
        }
    }
}

extension YapDB {

    public class Search: BaseView, YapDatabaseViewProducer, YapDatabaseViewRegistrar {

        public enum Handler {
            case ByKey(YapDatabaseFullTextSearchWithKeyBlock)
            case ByObject(YapDatabaseFullTextSearchWithObjectBlock)
            case ByMetadata(YapDatabaseFullTextSearchWithMetadataBlock)
            case ByRow(YapDatabaseFullTextSearchWithRowBlock)

            public var object: YapDatabaseFullTextSearchHandler {
                switch self {
                case let .ByKey(block):         return YapDatabaseFullTextSearchHandler.withKeyBlock(block)
                case let .ByObject(block):      return YapDatabaseFullTextSearchHandler.withObjectBlock(block)
                case let .ByMetadata(block):    return YapDatabaseFullTextSearchHandler.withMetadataBlock(block)
                case let .ByRow(block):         return YapDatabaseFullTextSearchHandler.withRowBlock(block)
                }
            }
        }

        let parent: YapDB.Fetch
        let searchName: String
        let columnNames: [String]
        let handler: Handler

        public init(name: String, parent p: YapDB.Fetch, search: String, columnNames cn: [String], handler h: Handler, version: String = "1.0", persistent: Bool = true, collections: [String]? = .None) {
            parent = p
            searchName = search
            columnNames = cn
            handler = h
            super.init(name: name, version: version, persistent: persistent, collections: collections)
        }

        func createDatabaseView() -> YapDatabaseView {
            return YapDatabaseSearchResultsView(fullTextSearchName: searchName, parentViewName: parent.name, versionTag: version, options: .None)
        }

        func registerInDatabase(database: YapDatabase, withConnection connection: YapDatabaseConnection? = .None) {

            if (database.registeredExtension(searchName) as? YapDatabaseFullTextSearch) == .None {
                let fullTextSearch = YapDatabaseFullTextSearch(columnNames: columnNames, handler: handler.object, versionTag: version)
                if let connection = connection {
                    database.registerExtension(fullTextSearch, withName: searchName, connection: connection)
                }
                else {
                    database.registerExtension(fullTextSearch, withName: searchName)
                }
            }

            if !isRegisteredInDatabase(database) {
                parent.registerInDatabase(database, withConnection: connection)
                if let connection = connection {
                    database.registerExtension(createDatabaseView(), withName: name, connection: connection)
                }
                else {
                    database.registerExtension(createDatabaseView(), withName: name)
                }
            }
        }
    }
}

extension YapDB {

    public struct Mappings {

        static var passThroughFilter: YapDatabaseViewMappingGroupFilter {
            return { (_, _) in true }
        }

        static var caseInsensitiveGroupSort: YapDatabaseViewMappingGroupSort {
            return { (group1, group2, _) in group1.caseInsensitiveCompare(group2) }
        }

        let filter: YapDatabaseViewMappingGroupFilter
        let sort: YapDatabaseViewMappingGroupSort

        public init(filter f: YapDatabaseViewMappingGroupFilter = Mappings.passThroughFilter, sort s: YapDatabaseViewMappingGroupSort = Mappings.caseInsensitiveGroupSort) {
            filter = f
            sort = s
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

        public init(fetch f: Fetch, mappings m: Mappings = Mappings(), block b: MappingsConfigurationBlock? = .None) {
            fetch = f
            mappings = m
            block = b
        }

        public init(view: YapDB.View) {
            self.init(fetch: .View(view))
        }

        public init(filter: YapDB.Filter) {
            self.init(fetch: .Filter(filter))
        }

        public init(search: YapDB.Search) {
            self.init(fetch: .Search(search))
        }

        func createMappingsRegisteredInDatabase(database: YapDatabase, withConnection connection: YapDatabaseConnection? = .None) -> YapDatabaseViewMappings {
            let databaseViewMappings = fetch.createViewMappings(mappings, inDatabase: database, withConnection: connection)
            block?(databaseViewMappings)
            return databaseViewMappings
        }
    }
}




