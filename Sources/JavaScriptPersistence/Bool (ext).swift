extension Bool: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .boolean(self) }
}
extension Bool: ConstructibleFromJSValue {
    @inlinable public static func construct(from value: JSValue) -> Bool? { value.boolean }
}
