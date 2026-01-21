import JSON

public final class JSObject {
    @usableFromInline var object: [String: JSValue]
    @usableFromInline var buffer: [JSValue]
    public let isArray: Bool

    @inlinable init(object: [String: JSValue], buffer: [JSValue], isArray: Bool) {
        self.object = object
        self.buffer = buffer
        self.isArray = isArray
    }
}
extension JSObject {
    @inlinable public static func object(_ properties: [String: JSValue] = [:]) -> JSObject {
        return JSObject(object: properties, buffer: [], isArray: false)
    }
    @inlinable public static func array(_ elements: [JSValue] = []) -> JSObject {
        return JSObject(object: [:], buffer: elements, isArray: true)
    }
}
extension JSObject {
    public static func json(_ json: JSON.Object) throws -> JSObject {
        var object: [String: JSValue] = .init(minimumCapacity: json.fields.count)
        for (key, value): (JSON.Key, JSON.Node) in json.fields {
            if case _? = object.updateValue(try .json(value), forKey: key.rawValue) {
                throw JSON.ObjectKeyError<JSON.Key>.duplicate(key)
            }
        }
        return .object(object)
    }
    public static func json(_ json: JSON.Array) throws -> JSObject {
        return .array(try json.elements.map(JSValue.json(_:)))
    }
}
extension JSObject: ConvertibleToJSValue {
    @inlinable public var jsValue: JSValue { .object(self) }
}
extension JSObject: ConstructibleFromJSValue {
    @inlinable public static func construct(from value: JSValue) -> JSObject? { value.object }
}
extension JSObject {
    @inlinable public var properties: [String: JSValue] { self.object }
    @inlinable public func push(_ value: JSValue) {
        self.buffer.append(value)
    }
}
extension JSObject {
    @inlinable public subscript(index: Int) -> JSValue {
        get {
            self.buffer.indices.contains(index) ? self.buffer[index] : .undefined
        }
        set(value) {
            if  self.buffer.endIndex < index {
                let count: Int = index.distance(to: self.buffer.endIndex)
                self.buffer.append(contentsOf: repeatElement(.undefined, count: count))
                self.buffer.append(value)
            } else if
                self.buffer.endIndex == index {
                self.buffer.append(value)
            } else {
                self.buffer[index] = value
            }
        }
    }
    @inlinable public subscript(key: JSString) -> JSValue {
        get {
            if self.isArray, key.string == "length" {
                return .number(Double.init(self.buffer.count))
            } else {
                return self.object[key.string] ?? .undefined
            }
        }
        set(value) {
            if self.isArray, key.string == "length" {
                guard
                let length: Int = .construct(from: value) else {
                    fatalError("Invalid array length")
                }
                if  length < self.buffer.count {
                    self.buffer.removeLast(self.buffer.count - length)
                } else if length > self.buffer.count {
                    self.buffer.reserveCapacity(length)
                    self.buffer.append(
                        contentsOf: repeatElement(.undefined, count: length - self.buffer.count)
                    )
                }
            } else {
                self.object[key.string] = value
            }
        }
    }
}
