#if swift(>=5.5)
extension JSON:Sendable {}
#endif 
/// A JSON variant value. This value may contain a fragment, an array, or an object.
/// 
/// You can parse JSON from any ``Collection`` of UTF-8 data using the ``JSON/.init(parsing:)``
/// initializer. For example, you can parse from a (sub)string via its 
/// ``StringProtocol//UTF8View``.
/// 
/// ```swift
/// let json:JSON = try .init(parsing: "{\"hello\": \"world\"}".utf8)
/// ```
/// 
/// All instances of this type, including ``JSON/.number(_:)?overload=s4JSONAAO6numberyA2B6NumberVcABmF`` 
/// instances, can be round-tripped losslessly, as long as the initial encoding is performed by 
/// ``/swift-json``. 
/// 
/// As of version 0.3.0, re-encoding a ``/swift-json``-encoded message is guaranteed to produce
/// bytewise-identical output.
/// 
/// When re-encoding arbitrary JSON, the implementation makes a reasonable effort to preserve 
/// features of the original input. It will not re-order object fields, strip explicit ``JSON/.null`` 
/// values, or convert decimals to floating point. The parser does *not* preserve structural 
/// whitespace.
/// 
/// The implementation guarantees *canonical equivalence* when re-encoding values, but it may not 
/// preserve the exact expressions used to represent them. For example, it will normalize the escape 
/// sequences in [`"6\\/14\\/1946"`]() to [`"6/14/1946"`](), because the escaped forward-slashes 
/// (`/`) are non-canonical.
/// 
/// ## Decoding with ``Codable``
/// 
/// `JSON` implements ``Decoder``, so you can use it with any type that conforms to 
/// ``Decodable``.
/// 
/// ## Decoding with high-performance APIs
/// 
/// The standard library’s decoding system suffers from inherent inefficiencies due to 
/// how it is defined. The *recommended* way to decode JSON is to use its 
/// ``JSON//LintingDictionary`` API, alongside this module’s ``Array`` extensions.
/// 
/// Most of `swift-json`’s linting and array APIs take closure arguments. You should perform 
/// decoding subtasks inside the closure bodies in order to take full advantage of the 
/// library’s error reporting.
/// 
/// These APIs are low-cost abstractions that only incur overhead when decoding fails. 
/// They can be significantly faster than the standard library’s ``Decoder`` hooks, and 
/// only slightly more verbose than an equivalent ``Decodable`` implementation.
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
    /// 
    /// >   Important: This function should *not* be called on an input to the ``string(_:)`` case 
    ///     constructor. The library performs string escaping lazily; calling this function 
    ///     explicitly will double-escape the input. 
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

    /// Wraps a signed integer as a numeric value.
    /// 
    /// Calling this function is equivalent to the following:
    ///
    /// ```swift 
    /// let json:JSON = .number(JSON.Number.init(signed))
    /// ```
    @inlinable public static 
    func number<T>(_ signed:T) -> Self where T:SignedInteger 
    {
        .number(.init(signed))
    }
    /// Wraps an usigned integer as a numeric value.
    /// 
    /// Calling this function is equivalent to the following:
    ///
    /// ```swift 
    /// let json:JSON = .number(JSON.Number.init(signed))
    /// ```
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