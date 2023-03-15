extension JSON
{
    @frozen public
    enum SingleField<Key>
    {
        case failure(SingleKeyError<Key>)
        case success(ExplicitField<Key>)
    }
}
extension JSON.SingleField:JSONScope
{
    /// Decodes the value of this field with the given decoder.
    /// Throws a ``JSON.DecodingError`` wrapping the underlying
    /// error if decoding fails.
    @inlinable public
    func decode<T>(with decode:(JSON) throws -> T) throws -> T
    {
        switch self
        {
        case .success(let field):
            return try field.decode(with: decode)

        case .failure(let error):
            throw error
        }
    }
}
