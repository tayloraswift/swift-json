extension Double: ConstructibleFromJSValue {}
extension Double: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .number(self) }
}
