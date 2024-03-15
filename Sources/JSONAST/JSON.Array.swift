extension JSON
{
    /// A JSON array, which can recursively contain instances of ``JSON``.
    /// This type is a transparent wrapper around a native [`[JSON]`]()
    /// array.
    @frozen public
    struct Array
    {
        public
        var elements:[JSON.Node]

        @inlinable public
        init(_ elements:[JSON.Node] = [])
        {
            self.elements = elements
        }
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
    init(arrayLiteral:JSON.Node...)
    {
        self.init(arrayLiteral)
    }
}
