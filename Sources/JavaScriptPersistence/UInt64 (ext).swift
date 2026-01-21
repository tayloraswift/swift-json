extension UInt64: ConstructibleFromJSValue {}
extension UInt64: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue {
        .bigInt(JSBigInt.init(int128: Int128.init(self)))
    }
}
