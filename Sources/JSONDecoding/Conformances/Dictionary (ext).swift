extension Dictionary:JSONDecodable where Key == String, Value:JSONDecodable
{
    /// Decodes an unordered dictionary from the given document. Dictionaries
    /// are not ``JSONEncodable``, because round-tripping them loses the field
    /// ordering information.
    @inlinable public
    init(json:JSON.Node) throws
    {
        try self.init(json: try .init(json: json))
    }
    @inlinable public
    init(json:JSON.Object) throws
    {
        self.init(minimumCapacity: json.count)
        for field:JSON.FieldDecoder<String> in json
        {
            if case _? = self.updateValue(try field.decode(to: Value.self), forKey: field.key)
            {
                throw JSON.ObjectKeyError<String>.duplicate(field.key)
            }
        }
    }
}
