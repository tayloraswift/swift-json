@frozen public struct JSString: Equatable {
    @usableFromInline let string: String

    @inlinable public init(_ string: String) {
        self.string = string
    }
}
extension JSString: ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral: String) {
        self.init(stringLiteral)
    }
}
extension JSString: CustomStringConvertible, LosslessStringConvertible {
    @inlinable public var description: String { self.string }
}
extension JSString: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .string(self) }
}
extension JSString: ConstructibleFromJSValue {
    @inlinable public static func construct(from value: JSValue) -> JSString? {
        guard case .string(let string) = value else {
            return nil
        }
        return string
    }
}
