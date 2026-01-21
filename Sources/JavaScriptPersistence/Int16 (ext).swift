extension Int16: ConstructibleFromJSValue {}
extension Int16: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .number(Double.init(self)) }
}
