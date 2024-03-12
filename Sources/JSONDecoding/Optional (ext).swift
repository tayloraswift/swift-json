extension Optional:JSONDecodable where Wrapped:JSONDecodable
{
    @inlinable public
    init(json:JSON.Node) throws
    {
        if  case .null = json
        {
            self = .none
        }
        else
        {
            self = .some(try .init(json: json))
        }
    }
}
