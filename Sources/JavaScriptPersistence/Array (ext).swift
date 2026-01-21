extension Array: ConvertibleToJSValue where Element: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue {
        .object(.array(self.map(\.jsValue)))
    }
}
extension Array: ConstructibleFromJSValue where Element: ConstructibleFromJSValue {
    @inlinable public static func construct(from value: JSValue) -> [Element]? {
        guard case .object(let object) = value, object.isArray else {
            return nil
        }

        var elements: [Element] = []
        ;   elements.reserveCapacity(object.buffer.count)
        for element: JSValue in object.buffer {
            guard let element: Element = .construct(from: element) else {
                return nil
            }
            elements.append(element)
        }
        return elements
    }
}
