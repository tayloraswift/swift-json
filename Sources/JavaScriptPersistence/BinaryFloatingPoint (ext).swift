extension BinaryFloatingPoint where Self: ConstructibleFromJSValue {
    @inlinable public static func construct(from value: JSValue) -> Self? {
        switch value {
        case .number(let value):
            return Self.init(value)
        case .bigInt(let value):
            return Self.init(exactly: value.int128)
        default:
            return nil
        }
    }
}
