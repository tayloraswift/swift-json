extension JSON:Decoder 
{
    @inlinable public 
    var codingPath:[any CodingKey] 
    {
        []
    }
    @inlinable public 
    var userInfo:[CodingUserInfoKey: Any] 
    {
        [:]
    }

    public 
    func singleValueContainer() -> SingleValueDecodingContainer
    {
        SingleValueDecoder.init(self, path: []) as SingleValueDecodingContainer
    }
    public 
    func unkeyedContainer() throws -> UnkeyedDecodingContainer
    {
        try SingleValueDecoder.init(self, path: []).unkeyedContainer()
    }
    public 
    func container<Key>(keyedBy _:Key.Type) throws -> KeyedDecodingContainer<Key> 
        where Key:CodingKey 
    {
        try SingleValueDecoder.init(self, path: []).container(keyedBy: Key.self)
    }
}
