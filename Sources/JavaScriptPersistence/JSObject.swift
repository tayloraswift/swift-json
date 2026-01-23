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
    @inlinable convenience public init(object: [String: JSValue]) {
        self.init(object: object, buffer: [], isArray: false)
    }
    @inlinable convenience public init(buffer: [JSValue]) {
        self.init(object: [:], buffer: buffer, isArray: true)
    }
}
extension JSObject {
    private convenience init(json: borrowing JSON.Object) throws {
        var object: [String: JSValue] = .init(minimumCapacity: json.fields.count)
        for (key, value): (JSON.Key, JSON.Node) in json.fields {
            if case _? = object.updateValue(try .init(json: value), forKey: key.rawValue) {
                throw JSON.ObjectKeyError<JSON.Key>.duplicate(key)
            }
        }
        self.init(object: object)
    }

    private convenience init(json: borrowing JSON.Array) throws {
        self.init(buffer: try json.elements.map(JSValue.init(json:)))
    }
}
extension JSObject {
    @inlinable public static func object(_ properties: [String: JSValue] = [:]) -> JSObject {
        .init(object: properties)
    }
    @inlinable public static func array(_ elements: [JSValue] = []) -> JSObject {
        .init(buffer: elements)
    }

    public static func json(_ json: JSON.Object) throws -> JSObject { try .init(json: json) }
    public static func json(_ json: JSON.Array) throws -> JSObject { try .init(json: json) }
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
extension JSObject: JSONEncodable {
    public func encode(to json: inout JSON) {
        if  self.isArray {
            self.buffer.encode(to: &json)
        } else {
            json(JSON.Key.self) {
                let fields: [(String, JSValue)] = self.object.sorted { $0.key < $1.key }
                for (key, value): (String, JSValue) in fields {
                    let key: JSON.Key = .init(rawValue: key)
                    $0[key] = value
                }
            }
        }
    }
}
extension JSObject: JSONDecodable {
    public convenience init(json: borrowing JSON.Node) throws {
        switch json {
        case .object(let json):
            try self.init(json: json)
        case .array(let json):
            try self.init(json: json)
        default:
            throw JSON.TypecastError<Self>.init(invalid: json)
        }
    }
}
