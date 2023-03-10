/// A type that can be decoded from a BSON dictionary-decoder.
public
protocol JSONObjectDecodable<CodingKeys>:JSONDecodable
{
    associatedtype CodingKeys:RawRepresentable<String> & Hashable = JSON.Key

    init(json:JSON.ObjectDecoder<CodingKeys>) throws
}
extension JSONObjectDecodable
{
    @inlinable public
    init(json:JSON.Object) throws
    {
        try self.init(json: try .init(indexing: json))
    }
    @inlinable public
    init(json:JSON) throws
    {
        try self.init(json: try .init(json: json))
    }
}
