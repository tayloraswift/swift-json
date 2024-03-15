extension JSON.Node:Decoder
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
    func singleValueContainer() -> any SingleValueDecodingContainer
    {
        JSON.SingleValueDecoder.init(self, path: []) as any SingleValueDecodingContainer
    }
    public
    func unkeyedContainer() throws -> any UnkeyedDecodingContainer
    {
        try JSON.SingleValueDecoder.init(self, path: []).unkeyedContainer()
    }
    public
    func container<Key>(keyedBy _:Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key:CodingKey
    {
        try JSON.SingleValueDecoder.init(self, path: []).container(keyedBy: Key.self)
    }
}
