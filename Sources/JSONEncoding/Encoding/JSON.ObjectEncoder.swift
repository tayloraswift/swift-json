extension JSON
{
    /// A thin wrapper around a native Swift dictionary providing an efficient decoding
    /// interface for a JSON object.
    @frozen public
    struct ObjectEncoder<CodingKey> where CodingKey:RawRepresentable<String> & Hashable
    {
        @usableFromInline internal
        var fields:[(key:Key, value:JSON)]
        
        @inlinable public
        init(fields:[(key:Key, value:JSON)])
        {
            self.fields = fields
        }
    }
}
extension JSON.ObjectEncoder:JSONBuilder
{
    @inlinable public
    init()
    {
        self.init(fields: [])
    }
    @inlinable public mutating
    func append(_ key:CodingKey, _ value:some JSONEncodable)
    {
        self.fields.append((.init(key), value.encoded(as: JSON.self)))
    }
}
