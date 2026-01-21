extension Int: ConstructibleFromJSValue {}
extension Int: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue {
        if  let double: Double = .init(exactly: self) {
            .number(double)
        } else {
            .bigInt(JSBigInt.init(int128: Int128.init(self)))
        }
    }
}
