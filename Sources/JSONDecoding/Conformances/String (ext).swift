extension String: JSONStringDecodable {
    @inlinable public init(json: borrowing JSON.Node) throws {
        self = try json.cast { $0.as(String.self) }
    }
}
