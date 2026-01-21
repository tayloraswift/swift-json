extension UInt8: ConstructibleFromJSValue {}
extension UInt8: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .number(Double.init(self)) }
}
