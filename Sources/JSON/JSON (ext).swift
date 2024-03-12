extension JSON
{
    /// Parses and decodes this raw JSON string as an instance of `Decodable`.
    @inlinable public
    func decode<Decodable>(_ type:Decodable.Type = Decodable.self) throws -> Decodable
        where Decodable:JSONDecodable
    {
        try .init(json: try JSON.Node.init(parsing: self))
    }

    /// Creates a raw JSON string by encoding the given instance of `Encodable`.
    @inlinable public static
    func encode<Encodable>(_ value:Encodable) -> Self
        where Encodable:JSONEncodable
    {
        var json:Self = .init(utf8: [])
        value.encode(to: &json)
        return json
    }
}
