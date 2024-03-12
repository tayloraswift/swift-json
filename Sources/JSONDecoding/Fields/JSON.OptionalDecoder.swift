extension JSON
{
    /// A field that may or may not exist in a document. This type is
    /// the return value of ``Dictionary``’s non-optional subscript, and
    /// is useful for obtaining structured diagnostics for “key-not-found”
    /// scenarios.
    @frozen public
    struct OptionalDecoder<Key> where Key:Sendable
    {
        public
        let key:Key
        public
        let value:JSON.Node?

        @inlinable public
        init(key:Key, value:JSON.Node?)
        {
            self.key = key
            self.value = value
        }
    }
}
extension JSON.OptionalDecoder
{
    @inlinable public static
    func ?? (lhs:Self, rhs:@autoclosure () -> Self) -> Self
    {
        if  case nil = lhs.value
        {
            rhs()
        }
        else
        {
            lhs
        }
    }
}
extension JSON.OptionalDecoder
{
    /// Gets the value of this key, throwing a ``JSON.ObjectKeyError``
    /// if it is [`nil`](). This is a distinct condition from an explicit
    /// ``JSON.null`` value, which will be returned without throwing an error.
    @inlinable public
    func decode() throws -> JSON.Node
    {
        if let value:JSON.Node = self.value
        {
            return value
        }
        else
        {
            throw JSON.ObjectKeyError<Key>.undefined(self.key)
        }
    }
}
extension JSON.OptionalDecoder:JSON.TraceableDecoder
{
    /// Decodes the value of this implicit field with the given decoder, throwing a
    /// ``JSON/ObjectKeyError`` if it does not exist. Throws a
    /// ``JSON/DecodingError`` wrapping the underlying error if decoding fails.
    @inlinable public
    func decode<T>(with decode:(JSON.Node) throws -> T) throws -> T
    {
        // we cannot *quite* shove this into the `do` block, because we
        // do not want to throw a ``DecodingError`` just because the key
        // was not found.
        let value:JSON.Node = try self.decode()
        do
        {
            return try decode(value)
        }
        catch let error
        {
            throw JSON.DecodingError.init(error, in: key)
        }
    }
}
