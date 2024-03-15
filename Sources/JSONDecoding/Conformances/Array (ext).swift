extension Array:JSONDecodable where Element:JSONDecodable
{
    @inlinable public
    init(json:JSON.Node) throws
    {
        try self.init(json: try .init(json: json))
    }
    @inlinable public
    init(json:JSON.Array) throws
    {
        self = try json.map { try $0.decode(to: Element.self) }
    }
}
