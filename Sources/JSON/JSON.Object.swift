import Grammar

extension JSON
{
    /// A string-keyed JSON object, which can recursively contain instances of
    /// ``JSON``. This type is a transparent wrapper around a native
    /// [`[(key:String, value:JSON)]`]() array.
    /// 
    /// JSON objects are more closely-related to ``KeyValuePairs`` than to
    /// ``Dictionary``, since object keys can occur more than once in the same
    /// object. However, most JSON schema allow clients to safely treat objects
    /// as ``Dictionary``-like containers.
    /// 
    /// The order of the ``fields`` in the payload reflects the order in which they 
    /// appear in the source object.
    /// 
    /// >   Warning: 
    ///     Many JSON encoders do not emit object fields in a stable order. Only 
    ///     assume a particular ordering based on careful observation or official 
    ///     documentation.
    /// 
    /// The object keys are not escaped.
    /// 
    /// >   Warning: 
    ///     Object keys can contain arbitrary unicode text. Don’t assume the 
    ///     keys are ASCII.
    @frozen public
    struct Object
    {
        public
        var fields:[(key:String, value:JSON)]

        @inlinable public
        init(_ fields:[(key:String, value:JSON)] = [])
        {
            self.fields = fields
        }
    }
}
extension JSON.Object
{
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
    }
    /// Creates a pseudo-object containing integral ``Number`` values taken
    /// from the supplied `number`, keyed by `"units"` and `"places"` and
    /// wrapped in containers of type ``Self``.
    ///
    /// This pseudo-object is intended for consumption by compiler-generated 
    /// ``Codable`` implementations. Decoding it incurs a small but non-zero 
    /// overhead when compared with calling ``Number``’s numeric casting
    /// methods directly.
    public
    init(encoding number:JSON.Number)
    {
        let units:JSON.Number = .init(sign: number.sign, units: number.units,  places: 0),
            places:JSON.Number = .init(sign:      .plus, units: number.places, places: 0)
        self.init([("units", .number(units)), ("places", .number(places))])
    }
}
extension JSON.Object
{
    /// Attempts to parse a JSON object from a string.
    ///
    /// >   Note:
    ///     Unlike with BSON lists, you cannot reparse JSON arrays as objects.
    @inlinable public 
    init(parsing string:some StringProtocol) throws
    {
        try self.init(parsing: string.utf8)
    }
    /// Attempts to parse a JSON object from UTF-8-encoded text.
    ///
    /// >   Note:
    ///     Unlike with BSON lists, you cannot reparse JSON arrays as objects.
    @inlinable public 
    init<UTF8>(parsing utf8:UTF8) throws where UTF8:Collection<UInt8>
    {
        self.init(try JSON.Rule<UTF8.Index>.Object.parse(utf8))
    }
}
extension JSON.Object:CustomStringConvertible
{
    /// Returns this object serialized as a minified string.
    /// 
    /// Reparsing and reserializing this string is guaranteed to return the 
    /// same string.
    public
    var description:String
    {
        "{\(self.fields.map{ "\(JSON.escape($0.key)):\($0.value)" }.joined(separator: ","))}"
    }
}
extension JSON.Object:ExpressibleByDictionaryLiteral 
{
    @inlinable public 
    init(dictionaryLiteral:(String, JSON)...) 
    {
        self.init(dictionaryLiteral)
    }
}
