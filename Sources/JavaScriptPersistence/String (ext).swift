extension String: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .string(JSString.init(self)) }
}
extension String: ConstructibleFromJSValue {
    @inlinable public static func construct(from value: JSValue) -> String? { value.string }
}
