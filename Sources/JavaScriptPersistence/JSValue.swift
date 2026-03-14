public import JSON

@frozen public struct JSValue {
    @usableFromInline let storage: Storage
    @inlinable init(storage: Storage) {
        self.storage = storage
    }
}
extension JSValue {
    @inlinable public static func boolean(_ value: Bool) -> Self {
        .init(storage: .boolean(value))
    }
    @inlinable public static func string(_ value: JSString) -> Self {
        .init(storage: .string(value))
    }
    @inlinable public static func number(_ value: Double) -> Self {
        .init(storage: .number(value))
    }
    @inlinable public static func object(_ value: JSObject) -> Self {
        .init(storage: .object(value))
    }
    @inlinable public static var null: Self {
        .init(storage: .null)
    }
    @inlinable public static var undefined: Self {
        .init(storage: .undefined)
    }
    @inlinable public static func symbol(_ value: JSSymbol) -> Self {
        .init(storage: .symbol(value))
    }
    @inlinable public static func bigInt(_ value: JSBigInt) -> Self {
        .init(storage: .bigInt(value))
    }
}
extension JSValue: JSONEncodable {
    public func encode(to json: inout JSON) {
        switch self.storage {
        case .null:
            (nil as Never?).encode(to: &json)
        case .boolean(let js):
            js.encode(to: &json)

        case .string(let js):
            js.string.encode(to: &json)

        case .number(let double):
            // ``Double`` can only represent integers up to 2^53, so any integer larger than
            // that would have been represented as ``JSBigInt`` instead
            if  let integer: Int64 = .init(exactly: double) {
                integer.encode(to: &json)
            } else {
                double.encode(to: &json)
            }

        case .object(let js):
            js.encode(to: &json)
        case .bigInt(let js):
            js.int128.encode(to: &json)
        case .undefined:
            // we wouldn’t want to encode null here, that’s different, and we can’t throw an
            // error either. doing nothing would still produce invalid JSON though. so trapping
            // is the least bad behavior.
            fatalError("undefined is not a valid JSON value")
        case .symbol:
            // the initializer for ``JSSymbol`` is internal, so it should be unreachable
            fatalError("symbols are not a valid JSON value")
        }
    }
}
extension JSValue: JSONDecodable {
    public init(json: borrowing JSON.Node) throws {
        switch json {
        case .null:
            self = .null
        case .bool(let json):
            self = .boolean(json)
        case .string(let json):
            self = .string(JSString.init(json.value))
        case .number(let json):
            switch json {
            case .fallback(let string):
                if  let int128: Int128 = .init(string) {
                    self = .number(int128)
                } else {
                    self = .number(parsing: string)
                }
            case .infinity(.plus):
                self = .number(.infinity)
            case .infinity(.minus):
                self = .number(-.infinity)
            case .inline(let json):
                if  let int128: Int128 = json.as(Int128.self) {
                    self = .number(int128)
                } else {
                    self = .number(parsing: "\(json)")
                }
            case .nan:
                self = .number(.nan)
            case .snan:
                self = .number(.signalingNaN)
            }
        case .object(let json):
            self = .object(try JSObject.json(json))
        case .array(let json):
            self = .object(try JSObject.json(json))
        }
    }
}
extension JSValue {
    private static func number(_ int128: Int128) -> JSValue {
        if  let double: Double = .init(exactly: int128) {
            return .number(double)
        } else {
            return .bigInt(JSBigInt.init(int128: int128))
        }
    }
    private static func number(parsing string: String) -> JSValue {
        if  let double: Double = .init(string) {
            return .number(double)
        } else {
            // this should have never passed parser validation in the first place
            fatalError("Unable to reparse JSON number to Double?!")
        }
    }
}
extension JSValue: ConstructibleFromJSValue {
    @inlinable public static func construct(from value: JSValue) -> Self? { value }
}
extension JSValue: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { self }
}
extension JSValue {
    @inlinable public var number: Double? {
        guard case .number(let value) = self.storage else {
            return nil
        }
        return value
    }

    @inlinable public var bigInt: JSBigInt? {
        guard case .bigInt(let value) = self.storage else {
            return nil
        }
        return value
    }
}
extension JSValue {
    @inlinable public var jsString: JSString? {
        guard case .string(let value) = self.storage else {
            return nil
        }
        return value
    }
}
extension JSValue {
    @inlinable public var boolean: Bool? {
        guard case .boolean(let value) = self.storage else {
            return nil
        }
        return value
    }

    @inlinable public var string: String? {
        guard case .string(let value) = self.storage else {
            return nil
        }
        return value.string
    }

    @inlinable public var object: JSObject? {
        guard case .object(let value) = self.storage else {
            return nil
        }
        return value
    }

    @inlinable public var symbol: JSSymbol? {
        guard case .symbol(let value) = self.storage else {
            return nil
        }
        return value
    }

    @inlinable public var isNull: Bool {
        guard case .null = self.storage else {
            return false
        }
        return true
    }

    @inlinable public var isUndefined: Bool {
        guard case .undefined = self.storage else {
            return false
        }
        return true
    }
}
