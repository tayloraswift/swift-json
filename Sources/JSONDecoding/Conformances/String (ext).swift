extension String:JSONStringDecodable
{
    @inlinable public
    init(json:JSON.Node) throws
    {
        self = try json.cast { $0.as(String.self) }
    }
}
