extension Array: JSONDecodable where Element: JSONDecodable {
    @inlinable public init(json: borrowing JSON.Node) throws {
        try self.init(json: try .init(json: json))
    }
}
extension Array where Element: JSONDecodable {
    @inlinable public init(json: borrowing JSON.Array) throws {
        self = try json.map { try $0.decode(to: Element.self) }
    }
}
