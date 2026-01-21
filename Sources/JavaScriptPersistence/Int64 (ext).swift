extension Int64: ConstructibleFromJSValue {}
extension Int64: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue {
        .bigInt(JSBigInt.init(int128: Int128.init(self)))
    }
}
