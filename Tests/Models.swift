//
//  Models.swift
//  YapDBExtensionsMobile
//
//  Created by Daniel Thorpe on 15/04/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import ValueCoding
import YapDatabase
import YapDatabaseExtensions

public enum Barcode: Equatable {
    case upca(Int, Int, Int, Int)
    case qrCode(String)
}

public struct Product: Identifiable, Equatable {

    public struct Category: Identifiable {
        public let identifier: Int
        let name: String
    }

    public struct Metadata: Equatable {
        let categoryIdentifier: Int

        public init(categoryIdentifier: Int) {
            self.categoryIdentifier = categoryIdentifier
        }
    }

    public let identifier: Identifier
    internal let name: String
    internal let barcode: Barcode

    public init(identifier: Identifier, name: String, barcode: Barcode) {
        self.identifier = identifier
        self.name = name
        self.barcode = barcode
    }
}

public struct Inventory: Identifiable, Equatable {
    let product: Product

    public var identifier: Identifier {
        return product.identifier
    }
}

open class NamedEntity: NSObject, NSCoding {

    open let identifier: Identifier
    open let name: String

    public init(id: String, name n: String) {
        identifier = id
        name = n
    }

    public required init?(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeObject(forKey: "identifier") as! Identifier
        name = aDecoder.decodeObject(forKey: "name") as! String
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(name, forKey: "name")
    }
}

open class Person: NamedEntity { }

open class Employee: NamedEntity {
}

open class Manager: NamedEntity {
    public struct Metadata: Equatable {
        public let numberOfDirectReports: Int
    }
}

// MARK: - Equatable

public func == (a: Barcode, b: Barcode) -> Bool {
    switch (a, b) {
    case let (.upca(aNS, aM, aP, aC), .upca(bNS, bM, bP, bC)):
        return (aNS == bNS) && (aM == bM) && (aP == bP) && (aC == bC)
    case let (.qrCode(aCode), .qrCode(bCode)):
        return aCode == bCode
    default:
        return false
    }
}

public func == (a: Product, b: Product) -> Bool {
    return a.identifier == b.identifier
}

public func == (a: Product.Metadata, b: Product.Metadata) -> Bool {
    return a.categoryIdentifier == b.categoryIdentifier
}

public func == (a: Inventory, b: Inventory) -> Bool {
    return (a.product == b.product)
}

public func == (a: NamedEntity, b: NamedEntity) -> Bool {
    return (a.identifier == b.identifier) && (a.name == b.name)
}

public func == (a: Manager.Metadata, b: Manager.Metadata) -> Bool {
    return a.numberOfDirectReports == b.numberOfDirectReports
}

// MARK: - Hashable etc

extension Barcode: Hashable {
    public var hashValue: Int {
        return identifier
    }
}

extension Product: Hashable {
    public var hashValue: Int {
        return barcode.hashValue
    }
}

extension Inventory: Hashable {
    public var hashValue: Int {
        return product.hashValue
    }
}

extension Product.Metadata: Hashable {
    public var hashValue: Int {
        return categoryIdentifier.hashValue
    }
}

extension Manager.Metadata: Hashable {
    public var hashValue: Int {
        return numberOfDirectReports.hashValue
    }
}

extension NamedEntity {

    open override var description: String {
        return "id: \(identifier), name: \(name)"
    }
}

// MARK: - Persistable

extension Barcode: Persistable {

    public static var collection: String {
        return "Barcodes"
    }

    public var identifier: Int {
        switch self {
        case let .upca(numberSystem, manufacturer, product, check):
            return "\(numberSystem).\(manufacturer).\(product).\(check)".hashValue
        case let .qrCode(code):
            return code.hashValue
        }
    }
}

extension Product.Category: Persistable {

    public static var collection: String {
        return "Categories"
    }
}

extension Product: Persistable {

    public static var collection: String {
        return "Products"
    }
}

extension Inventory: Persistable {

    public static var collection: String {
        return "Inventory"
    }
}

extension Person: Persistable {

    public static var collection: String {
        return "People"
    }
}

extension Employee: Persistable {

    public static var collection: String {
        return "Employees"
    }
}

extension Manager: Persistable {

    public static var collection: String {
        return "Managers"
    }
}


// MARK: - ValueCoding

extension Barcode: ValueCoding {
    public typealias Coder = BarcodeCoder

    enum Kind: Int { case upca = 1, qrCode }

    var kind: Kind {
        switch self {
        case .upca(_): return Kind.upca
        case .qrCode(_): return Kind.qrCode
        }
    }
}

extension Product.Category: ValueCoding {
    public typealias Coder = ProductCategoryCoder
}

extension Product.Metadata: ValueCoding {
    public typealias Coder = ProductMetadataCoder
}

extension Product: ValueCoding {
    public typealias Coder = ProductCoder
}

extension Inventory: ValueCoding {
    public typealias Coder = InventoryCoder
}

extension Manager.Metadata: ValueCoding {
    public typealias Coder = ManagerMetadataCoder
}


// MARK: - Coders

open class BarcodeCoder: NSObject, NSCoding, CodingProtocol {
    open let value: Barcode

    public required init(_ v: Barcode) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        if let kind = Barcode.Kind(rawValue: aDecoder.decodeInteger(forKey: "kind")) {
            switch kind {
            case .upca:
                let numberSystem = aDecoder.decodeInteger(forKey: "numberSystem")
                let manufacturer = aDecoder.decodeInteger(forKey: "manufacturer")
                let product = aDecoder.decodeInteger(forKey: "product")
                let check = aDecoder.decodeInteger(forKey: "check")
                value = .upca(numberSystem, manufacturer, product, check)
            case .qrCode:
                let code = aDecoder.decodeObject(forKey: "code") as! String
                value = .qrCode(code)
            }
        }
        else {
            preconditionFailure("Barcode.Kind not correctly encoded.")
        }
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(value.kind.rawValue, forKey: "kind")
        switch value {
        case let .upca(numberSystem, manufacturer, product, check):
            aCoder.encode(numberSystem, forKey: "numberSystem")
            aCoder.encode(manufacturer, forKey: "manufacturer")
            aCoder.encode(product, forKey: "product")
            aCoder.encode(check, forKey: "check")
        case let .qrCode(code):
            aCoder.encode(code, forKey: "code")
        }
    }
}

open class ProductCategoryCoder: NSObject, NSCoding, CodingProtocol {
    open let value: Product.Category

    public required init(_ v: Product.Category) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let identifier = aDecoder.decodeInteger(forKey: "identifier")
        let name = aDecoder.decodeObject(forKey: "name") as? String
        value = Product.Category(identifier: identifier, name: name!)
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(value.identifier, forKey: "identifier")
        aCoder.encode(value.name, forKey: "name")
    }
}

open class ProductMetadataCoder: NSObject, NSCoding, CodingProtocol {
    open let value: Product.Metadata

    public required init(_ v: Product.Metadata) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let categoryIdentifier = aDecoder.decodeInteger(forKey: "categoryIdentifier")
        value = Product.Metadata(categoryIdentifier: categoryIdentifier)
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(value.categoryIdentifier, forKey: "categoryIdentifier")
    }
}

open class ProductCoder: NSObject, NSCoding, CodingProtocol {
    open let value: Product

    public required init(_ v: Product) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let identifier = aDecoder.decodeObject(forKey: "identifier") as! String
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let barcode = Barcode.decode(aDecoder.decodeObject(forKey: "barcode"))
        value = Product(identifier: identifier, name: name, barcode: barcode!)
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(value.identifier, forKey: "identifier")
        aCoder.encode(value.name, forKey: "name")
        aCoder.encode(value.barcode.encoded, forKey: "barcode")
    }
}

open class InventoryCoder: NSObject, NSCoding, CodingProtocol {
    open let value: Inventory

    public required init(_ v: Inventory) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let product = Product.decode(aDecoder.decodeObject(forKey: "product"))
        value = Inventory(product: product!)
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(value.product.encoded, forKey: "product")
    }
}


open class ManagerMetadataCoder: NSObject, NSCoding, CodingProtocol {
    open let value: Manager.Metadata

    public required init(_ v: Manager.Metadata) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let numberOfDirectReports = aDecoder.decodeInteger(forKey: "numberOfDirectReports")
        value = Manager.Metadata(numberOfDirectReports: numberOfDirectReports)
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(value.numberOfDirectReports, forKey: "numberOfDirectReports")
    }
}

// MARK: - Database Views

public func products() -> YapDB.Fetch {

    let grouping: YapDB.View.Grouping = .byMetadata({ (_, collection, key, metadata) -> String! in
        if collection == Product.collection {
            if let metadata = Product.Metadata.decode(metadata) {
                return "category: \(metadata.categoryIdentifier)"
            }
        }
        return nil
    })

    let sorting: YapDB.View.Sorting = .byObject({ (_, group, collection1, key1, object1, collection2, key2, object2) -> ComparisonResult in
        if let product1 = Product.decode(object1) {
            if let product2 = Product.decode(object2) {
                return product1.name.caseInsensitiveCompare(product2.name)
            }
        }
        return .orderedSame
    })

    let view = YapDB.View(
        name: "Products grouped by category",
        grouping: grouping,
        sorting: sorting,
        collections: [Product.collection])

    return .view(view)
}




