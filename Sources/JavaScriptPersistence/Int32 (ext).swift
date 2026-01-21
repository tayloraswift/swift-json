extension Int32: ConstructibleFromJSValue {}
extension Int32: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .number(Double.init(self)) }
}
