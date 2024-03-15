extension Never:JSONDecodable
{
    /// Always throws a ``JSON.TypecastError``.
    @inlinable public
    init(json:JSON.Node) throws
    {
        throw JSON.TypecastError<Never>.init(invalid: json)
    }
}
