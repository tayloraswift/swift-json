#if swift(>=5.5)
extension JSON:Sendable {}
#endif 
/// A JSON variant value. This value may contain a fragment, an array, or an object.
/// 
/// All instances of this type, including ``number(_:)`` instances, can be round-tripped 
/// losslessly, as long as the initial encoding is performed by ``/swift-json``. 
/// 
/// Re-encoding arbitrary JSON is not guaranteed to produce the exact same result, 
/// although the implementation makes a reasonable effort to preserve features of 
/// the original input.
@frozen public
enum JSON
{
    // TODO: optimize this, it should operate at the utf8 level, and be @inlinable 

    /// Escapes and formats a string as a JSON string literal, including the 
    /// beginning and ending quote characters.
    /// -   Parameters:
    ///     - string: A string to escape.
    /// -   Returns: A string literal, which includes the [`""`]() delimiters.
    ///
    /// This function escapes the following characters: `"`, `\`, `\b`, `\t`, `\n`, 
    /// `\f`, and `\r`. It does not escape forward slashes (`/`).
    /// 
    /// JSON string literals may contain unicode characters, even after escaping. 
    /// Do not assume the output of this function is ASCII.
    public static 
    func escape<S>(_ string:S) -> String where S:StringProtocol
    {
        var escaped:String = "\""
        for character:Character in string 
        {
            switch character
            {
            case "\"":      escaped += "\\\""
            case "\\":      escaped += "\\\\"
            // slash escape is not mandatory, and does not improve legibility
            // case "/":       escaped += "\\/"
            case "\u{08}":  escaped += "\\b"
            case "\u{09}":  escaped += "\\t"
            case "\u{0A}":  escaped += "\\n"
            case "\u{0C}":  escaped += "\\f"
            case "\u{0D}":  escaped += "\\r"
            default:        escaped.append(character)
            }
        }
        escaped += "\""
        return escaped
    }
    
    /// A null value. 
    /// 
    /// This is conceptually equivalent to ``Void``, and should 
    /// not be confused with [`nil`]() in Swift. It represents an empty value, 
    /// *not* the absence of a value.
    case null 
    /// A boolean value. 
    case bool(Bool)
    /// A numerical value.
    case number(Number)
    /// A string value.
    /// 
    /// The contents of this string are *not* escaped. If you are creating an 
    /// instance of [`Self`]() for serialization with this case-constructor, 
    /// do not escape the input.
    case string(String)
    /// An array, which can recursively contain instances of [`Self`]().
    case array([Self])
    /// A ``String``-keyed object, which can recursively contain instances of [`Self`]().
    /// 
    /// This is more closely-related to ``KeyValuePairs`` than to ``Dictionary``, 
    /// since object keys can occur more than once in the same object. However, 
    /// most JSON APIs allow clients to safely treat objects as ``Dictionary``-like 
    /// containers.
    /// 
    /// The order of the items in the payload reflects the order in which they 
    /// appear in the source object.
    /// 
    /// >   Warning: 
    ///     Many JSON APIs do not encode object items in a stable order. Only 
    ///     assume a particular ordering based on careful observation or official 
    ///     documentation.
    /// 
    /// The keys in the payload are *not* escaped.
    /// 
    /// >   Warning: 
    ///     Object keys can contain arbitrary unicode text. Don’t assume the 
    ///     keys are ASCII.
    case object([(key:String, value:Self)])

    @inlinable public static 
    func number<T>(_ signed:T) -> Self where T:SignedInteger 
    {
        .number(.init(signed))
    }
    @inlinable public static 
    func number<T>(_ unsigned:T) -> Self where T:UnsignedInteger 
    {
        .number(.init(unsigned))
    }
}

extension JSON:CustomStringConvertible 
{
    /// Returns this value serialized as a minified string.
    /// 
    /// Reparsing and reserializing this string is guaranteed to return the 
    /// same string.
    public
    var description:String
    {
        switch self 
        {
        case .null:
            return "null"
        case .bool(true):
            return "true"
        case .bool(false):
            return "false"
        case .number(let value):
            return value.description
        case .string(let string):
            return Self.escape(string)
        case .array(let elements):
            return "[\(elements.map(\.description).joined(separator: ","))]"
        case .object(let items):
            return "{\(items.map{ "\(Self.escape($0.key)):\($0.value)" }.joined(separator: ","))}"
        }
    }
}
extension JSON:ExpressibleByDictionaryLiteral 
{
    @inlinable public 
    init(dictionaryLiteral:(String, Self)...) 
    {
        self = .object(dictionaryLiteral)
    }
}
extension JSON:ExpressibleByArrayLiteral 
{
    @inlinable public 
    init(arrayLiteral:Self...) 
    {
        self = .array(arrayLiteral)
    }
}
extension JSON:ExpressibleByStringLiteral 
{
    @inlinable public 
    init(stringLiteral:String) 
    {
        self = .string(stringLiteral)
    }
}
extension JSON:ExpressibleByBooleanLiteral
{
    @inlinable public 
    init(booleanLiteral:Bool) 
    {
        self = .bool(booleanLiteral)
    }
}