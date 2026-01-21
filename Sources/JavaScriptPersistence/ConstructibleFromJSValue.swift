public protocol ConstructibleFromJSValue {
    static func construct(from value: JSValue) -> Self?
}
extension ConstructibleFromJSValue where Self: SignedInteger {
    @inlinable public static func construct(from value: JSValue) -> Self? {
        switch value {
        case .number(let value): .init(exactly: value)
        case .bigInt(let value): .init(exactly: value.int128)
        default: nil
        }
    }
}
extension ConstructibleFromJSValue where Self: UnsignedInteger {
    @inlinable public static func construct(from value: JSValue) -> Self? {
        switch value {
        case .number(let number): Self.init(exactly: number)
        case .bigInt(let bigInt): Self.init(exactly: bigInt.int128)
        default: nil
        }
    }
}
