extension Float:JSONDecodable
{
    @inlinable public
    init(json:JSON.Node) throws
    {
        self = try json.cast { $0.as(Self.self) }
    }
}
