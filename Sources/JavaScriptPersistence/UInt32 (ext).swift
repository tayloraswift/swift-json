extension UInt32: ConstructibleFromJSValue {}
extension UInt32: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .number(Double.init(self)) }
}
