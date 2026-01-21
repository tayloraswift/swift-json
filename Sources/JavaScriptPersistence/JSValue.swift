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
extension JSValue {
    public static func json(_ json: JSON.Node) throws -> JSValue {
        switch json {
        case .null:
            return .null
        case .bool(let json):
            return .boolean(json)
        case .string(let json):
            return .string(JSString.init(json.value))
        case .number(let json):
            switch json {
            case .fallback(let self):
                return .number(Int128.init(self), else: self)
            case .infinity(.plus):
                return .number(.infinity)
            case .infinity(.minus):
                return .number(-.infinity)
            case .inline(let self):
                return .number(self.as(Int128.self), else: "\(self)")
            case .nan:
                return .number(.nan)
            case .snan:
                return .number(.signalingNaN)
            }
        case .object(let json):
            return .object(try JSObject.json(json))
        case .array(let json):
            return .object(try JSObject.json(json))
        }
    }

    private static func number(
        _ int128: Int128?,
        else string: @autoclosure () -> String
    ) -> JSValue {
        if  let int128: Int128 {
            if  let double: Double = .init(exactly: int128) {
                return .number(double)
            } else {
                return .bigInt(JSBigInt.init(int128: int128))
            }
        } else {
            if  let double: Double = .init(string()) {
                return .number(double)
            } else {
                // this should have never passed parser validation in the first place
                fatalError("Unable to reparse JSON number to Double?!")
            }
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
