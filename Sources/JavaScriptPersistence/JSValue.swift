import JSON

@frozen public enum JSValue {
    case boolean(Bool)
    case string(JSString)
    case number(Double)
    case object(JSObject)
    case null
    case undefined
    case symbol(JSSymbol)
    case bigInt(JSBigInt)
}
extension JSValue: JSONEncodable {
    public func encode(to json: inout JSON) {
        switch self {
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
    @available(
        *, unavailable,
        message: "code that expects a numeric value should check for 'BigInt' as well"
    ) @inlinable public var number: Double? {
        guard case .number(let value) = self else {
            return nil
        }
        return value
    }

    @available(
        *, unavailable,
        message: "code that expects a numeric value should check for 'Double' as well"
    ) @inlinable public var bigInt: JSBigInt? {
        guard case .bigInt(let value) = self else {
            return nil
        }
        return value
    }
}
extension JSValue {
    @inlinable public var boolean: Bool? {
        guard case .boolean(let value) = self else {
            return nil
        }
        return value
    }

    @inlinable public var string: String? {
        guard case .string(let value) = self else {
            return nil
        }
        return value.string
    }

    @inlinable public var object: JSObject? {
        guard case .object(let value) = self else {
            return nil
        }
        return value
    }

    @inlinable public var symbol: JSSymbol? {
        guard case .symbol(let value) = self else {
            return nil
        }
        return value
    }

    @inlinable public var isNull: Bool {
        guard case .null = self else {
            return false
        }
        return true
    }

    @inlinable public var isUndefined: Bool {
        guard case .undefined = self else {
            return false
        }
        return true
    }
}
