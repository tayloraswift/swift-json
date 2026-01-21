extension Int8: ConstructibleFromJSValue {}
extension Int8: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .number(Double.init(self)) }
}
