/// A type that can be decoded from a JSON dictionary-decoder.
public
protocol JSONObjectDecodable<CodingKey>:JSONDecodable
{
    associatedtype CodingKey:RawRepresentable<String> & Hashable & Sendable = JSON.Key

    init(json:JSON.ObjectDecoder<CodingKey>) throws
}
extension JSONObjectDecodable
{
    @inlinable public
    init(json:JSON.Object) throws
    {
        try self.init(json: try .init(indexing: json))
    }
    @inlinable public
    init(json:JSON.Node) throws
    {
        try self.init(json: try .init(json: json))
    }
}
