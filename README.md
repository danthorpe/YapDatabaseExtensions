# YapDatabaseExtensions

[![Build status](https://badge.buildkite.com/95784c169af7db5e36cefe146d5d3f3899c8339d46096a6349.svg)](https://buildkite.com/danthorpe/yapdatabaseextensions)

## Requirements

YapDatabase :)

## Installation

YapDatabaseExtensions is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YapDatabaseExtensions'
```

## Usage

This framework defines a `Persistable` protocol which should be implemented on your types which get stored in YapDatabase.

```swift

public protocol Identifiable {
    typealias IdentifierType: Printable
    var identifier: IdentifierType { get }
}

public protocol Persistable: Identifiable {
    static var collection: String { get }
}

```

Typically, it would be implemented like so:

```swift
extension User: Persistable, Identifiable {

	static var collection: String { 
    	return "Users"
    }
    
    var identifier: Int { 
    	return userId
    }
}
```

assuming that `userId` is a unique identifier for the type. There is also `MetadataPersistable` protocols which can be used to expose metadata on the type. Note that `String` doesn't actually conform to `Printable` but it's implemented in an extension on a typealias called `Identifier`.

Provided in extensions on `YapDatabase`, `YapDatabaseConnection`, `YapDatabaseReadTransaction` and `YapDatabaseWriteTransaction` are methods to read, save, remove and replace persistable items.

### Using value types in YapDatabase

To use struct or enum types with YapDatabase requires implementing the `Saveable` protocol, in addition to `Persistable`. `Saveable` in turn requires an `Archiver` type. This essentially, expose a class which implements `NSCoding` as an archiving adaptor for your value type. 

For example, this is the Barcode enum from "The Swift Programming Language" book:

```swift

enum Barcode {
	case UPCA(Int, Int, Int, Int)
	case QRCode(String)
}

```

It can be saved in YapDatabase with the following extension:

```swift

extension Barcode: Persistable {

    static var collection: String {
        return "Barcodes"
    }

    var identifier: Int {
        switch self {
        case let .UPCA(numberSystem, manufacturer, product, check):
            return "\(numberSystem).\(manufacturer).\(product).\(check)".hashValue
        case let .QRCode(code):
            return code.hashValue
        }
    }
}

extension Barcode: Saveable {

    typealias Archive = BarcodeArchiver

	enum Kind: Int { case UPCA = 1, QRCode }

    var archive: Archive {
        return Archive(self)
    }

	var kind: Kind {
		switch self {
		case UPCA(_): return Kind.UPCA
		case QRCode(_): return Kind.QRCode
		}
	}
}

class BarcodeArchiver: NSObject, NSCoding, Archiver {
	let value: Barcode

    required init(_ v: Barcode) {
        value = v
    }

    required init(coder aDecoder: NSCoder) {
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
		preconditionFailure("Barcode.Kind not correctly encoded.")
    }

    func encodeWithCoder(aCoder: NSCoder) {
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

```

This may look like quite a bit of code, but it's really just NSCoding, which you probably already have inside on your classes, so it's actually just moving code from being directly in the type interface off to one side. This can help keep your domain types clean and easy to comprehend. See the example project for more examples of implementations of `Saveable`, including nesting value types.

### Asynchronous save, PromiseKit, BrightFutures etc
The default subspec provides asynchronous methods using callback closures. 

Additionally, use the appropriate subspec for your favourite FRP library for appropriate asynchronous return types. For example:

```ruby
pod 'YapDatabaseExtensions/PromiseKit'
```

will make APIs such as the following available:

```swift
public func asyncSaveValue<V where V: Saveable, V: Persistable, V.ArchiverType.ValueType == V>(value: V) -> Promise<V>
```

Currently supported are PromiseKit, BrightFutures & SwiftTask. RAC 3.0 support is forthcoming, please create issues or submit pull requests if I'm missing support for your favourite library.

## Author

Daniel Thorpe, @danthorpe

## License

YapDatabaseExtensions is available under the MIT license. See the LICENSE file for more info.
