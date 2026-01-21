extension Float: ConstructibleFromJSValue {}
extension Float: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .number(Double.init(self)) }
}
