import Grammar

extension JSON
{
    /// A JSON array, which can recursively contain instances of ``JSON``.
    /// This type is a transparent wrapper around a native [`[JSON]`]()
    /// array.
    @frozen public
    struct Array
    {
        public
        var elements:[JSON]

        @inlinable public
        init(_ elements:[JSON] = [])
        {
            self.elements = elements
        }
    }
}
extension JSON.Array
{
    /// Attempts to parse a JSON array from a string.
    @inlinable public 
    init(parsing string:some StringProtocol) throws
    {
        try self.init(parsing: string.utf8)
    }
    /// Attempts to parse a JSON array from UTF-8-encoded text.
    @inlinable public 
    init<UTF8>(parsing utf8:UTF8) throws where UTF8:Collection<UInt8>
    {
        self.init(try JSON.Rule<UTF8.Index>.Array.parse(utf8))
    }
}
extension JSON.Array:CustomStringConvertible
{
    /// Returns this array serialized as a minified string.
    /// 
    /// Reparsing and reserializing this string is guaranteed to return the 
    /// same string.
    public
    var description:String
    {
        "[\(self.elements.map(\.description).joined(separator: ","))]"
    }
}
extension JSON.Array:ExpressibleByArrayLiteral 
{
    @inlinable public 
    init(arrayLiteral:JSON...) 
    {
        self.init(arrayLiteral)
    }
}
