extension JSON
{
    @frozen public
    struct ExplicitField<Key>
    {
        public
        let key:Key
        public
        let value:JSON

        @inlinable public
        init(key:Key, value:JSON)
        {
            self.key = key
            self.value = value
        }
    }
}
extension JSON.ExplicitField:JSONScope
{
    /// Decodes the value of this field with the given decoder.
    /// Throws a ``JSON.DecodingError`` wrapping the underlying
    /// error if decoding fails.
    @inlinable public
    func decode<T>(with decode:(JSON) throws -> T) throws -> T
    {
        do
        {
            return try decode(self.value)
        }
        catch let error 
        {
            throw JSON.DecodingError.init(error, in: self.key)
        }
    }
}
