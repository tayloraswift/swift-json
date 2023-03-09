extension JSON
{
    @frozen public
    struct Key:Hashable, RawRepresentable, Sendable
    {
        public
        let rawValue:String

        @inlinable public
        init(rawValue:String)
        {
            self.rawValue = rawValue
        }
    }
}
extension JSON.Key
{
    @inlinable public
    init(_ other:some RawRepresentable<String>)
    {
        self.init(rawValue: other.rawValue)
    }
    public
    init(_ codingKey:some CodingKey)
    {
        self.init(rawValue: codingKey.stringValue)
    }

    /// Returns the raw value of this key with special characters
    /// escaped.
    var escaped:String
    {
        JSON.escape(self.rawValue)
    }
}
extension JSON.Key:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension JSON.Key:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
