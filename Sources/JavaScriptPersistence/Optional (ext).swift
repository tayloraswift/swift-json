extension Optional: ConstructibleFromJSValue where Wrapped: ConstructibleFromJSValue {
    @inlinable public static func construct(from value: JSValue) -> Self? {
        switch value {
        case .null, .undefined:
            return .some(nil)
        default:
            guard let wrapped: Wrapped = .construct(from: value) else {
                return nil
            }
            return .some(wrapped)
        }
    }
}
extension Optional: ConvertibleToJSValue where Wrapped: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue {
        self?.jsValue ?? .null
    }
}
