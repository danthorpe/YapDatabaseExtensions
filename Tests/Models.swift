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
    case UPCA(Int, Int, Int, Int)
    case QRCode(String)
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

public class NamedEntity: NSObject, NSCoding {

    public let identifier: Identifier
    public let name: String

    public init(id: String, name n: String) {
        identifier = id
        name = n
    }

    public required init?(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeObjectForKey("identifier") as! Identifier
        name = aDecoder.decodeObjectForKey("name") as! String
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(identifier, forKey: "identifier")
        aCoder.encodeObject(name, forKey: "name")
    }
}

public class Person: NamedEntity { }

public class Employee: NamedEntity {
}

public class Manager: NamedEntity {
    public struct Metadata: Equatable {
        public let numberOfDirectReports: Int
    }
}

// MARK: - Equatable

public func == (a: Barcode, b: Barcode) -> Bool {
    switch (a, b) {
    case let (.UPCA(aNS, aM, aP, aC), .UPCA(bNS, bM, bP, bC)):
        return (aNS == bNS) && (aM == bM) && (aP == bP) && (aC == bC)
    case let (.QRCode(aCode), .QRCode(bCode)):
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

    public override var description: String {
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
        case let .UPCA(numberSystem, manufacturer, product, check):
            return "\(numberSystem).\(manufacturer).\(product).\(check)".hashValue
        case let .QRCode(code):
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

    enum Kind: Int { case UPCA = 1, QRCode }

    var kind: Kind {
        switch self {
        case UPCA(_): return Kind.UPCA
        case QRCode(_): return Kind.QRCode
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

public class BarcodeCoder: NSObject, NSCoding, CodingType {
    public let value: Barcode

    public required init(_ v: Barcode) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        if let kind = Barcode.Kind(rawValue: aDecoder.decodeIntegerForKey("kind")) {
            switch kind {
            case .UPCA:
                let numberSystem = aDecoder.decodeIntegerForKey("numberSystem")
                let manufacturer = aDecoder.decodeIntegerForKey("manufacturer")
                let product = aDecoder.decodeIntegerForKey("product")
                let check = aDecoder.decodeIntegerForKey("check")
                value = .UPCA(numberSystem, manufacturer, product, check)
            case .QRCode:
                let code = aDecoder.decodeObjectForKey("code") as! String
                value = .QRCode(code)
            }
        }
        else {
            preconditionFailure("Barcode.Kind not correctly encoded.")
        }
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(value.kind.rawValue, forKey: "kind")
        switch value {
        case let .UPCA(numberSystem, manufacturer, product, check):
            aCoder.encodeInteger(numberSystem, forKey: "numberSystem")
            aCoder.encodeInteger(manufacturer, forKey: "manufacturer")
            aCoder.encodeInteger(product, forKey: "product")
            aCoder.encodeInteger(check, forKey: "check")
        case let .QRCode(code):
            aCoder.encodeObject(code, forKey: "code")
        }
    }
}

public class ProductCategoryCoder: NSObject, NSCoding, CodingType {
    public let value: Product.Category

    public required init(_ v: Product.Category) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let identifier = aDecoder.decodeIntegerForKey("identifier")
        let name = aDecoder.decodeObjectForKey("name") as? String
        value = Product.Category(identifier: identifier, name: name!)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(value.identifier, forKey: "identifier")
        aCoder.encodeObject(value.name, forKey: "name")
    }
}

public class ProductMetadataCoder: NSObject, NSCoding, CodingType {
    public let value: Product.Metadata

    public required init(_ v: Product.Metadata) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let categoryIdentifier = aDecoder.decodeIntegerForKey("categoryIdentifier")
        value = Product.Metadata(categoryIdentifier: categoryIdentifier)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(value.categoryIdentifier, forKey: "categoryIdentifier")
    }
}

public class ProductCoder: NSObject, NSCoding, CodingType {
    public let value: Product

    public required init(_ v: Product) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let identifier = aDecoder.decodeObjectForKey("identifier") as! String
        let name = aDecoder.decodeObjectForKey("name") as! String
        let barcode = Barcode.decode(aDecoder.decodeObjectForKey("barcode"))
        value = Product(identifier: identifier, name: name, barcode: barcode!)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.identifier, forKey: "identifier")
        aCoder.encodeObject(value.name, forKey: "name")
        aCoder.encodeObject(value.barcode.encoded, forKey: "barcode")
    }
}

public class InventoryCoder: NSObject, NSCoding, CodingType {
    public let value: Inventory

    public required init(_ v: Inventory) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let product = Product.decode(aDecoder.decodeObjectForKey("product"))
        value = Inventory(product: product!)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.product.encoded, forKey: "product")
    }
}


public class ManagerMetadataCoder: NSObject, NSCoding, CodingType {
    public let value: Manager.Metadata

    public required init(_ v: Manager.Metadata) {
        value = v
    }

    public required init?(coder aDecoder: NSCoder) {
        let numberOfDirectReports = aDecoder.decodeIntegerForKey("numberOfDirectReports")
        value = Manager.Metadata(numberOfDirectReports: numberOfDirectReports)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(value.numberOfDirectReports, forKey: "numberOfDirectReports")
    }
}

// MARK: - Database Views

public func products() -> YapDB.Fetch {

    let grouping: YapDB.View.Grouping = .ByMetadata({ (_, collection, key, metadata) -> String! in
        if collection == Product.collection {
            if let metadata = Product.Metadata.decode(metadata) {
                return "category: \(metadata.categoryIdentifier)"
            }
        }
        return nil
    })

    let sorting: YapDB.View.Sorting = .ByObject({ (_, group, collection1, key1, object1, collection2, key2, object2) -> NSComparisonResult in
        if let product1 = Product.decode(object1) {
            if let product2 = Product.decode(object2) {
                return product1.name.caseInsensitiveCompare(product2.name)
            }
        }
        return .OrderedSame
    })

    let view = YapDB.View(
        name: "Products grouped by category",
        grouping: grouping,
        sorting: sorting,
        collections: [Product.collection])

    return .View(view)
}




