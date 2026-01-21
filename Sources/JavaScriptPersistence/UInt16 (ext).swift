extension UInt16: ConstructibleFromJSValue {}
extension UInt16: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .number(Double.init(self)) }
}
