import Grammar

/// A JSON variant value. This value may contain a fragment, an array, or an object.
/// 
/// You can parse JSON from any ``Collection`` of UTF-8 data using the ``init(parsing:)``
/// initializer. For example, you can parse from a (sub)string via its 
/// ``StringProtocol UTF8View``.
/// 
/// ```swift
/// let json:JSON = try .init(parsing: "{\"hello\": \"world\"}".utf8)
/// ```
///
/// When re-encoding arbitrary JSON, the implementation makes a reasonable effort to
/// preserve important features of the original input. The library will not re-order
/// object fields, strip explicit ``case null`` values, or convert decimals to floating
/// point. However the parser does *not* preserve structural whitespace.
/// 
/// The implementation guarantees *canonical equivalence* when re-encoding values, but
/// it may not preserve the exact expressions used to represent them. For example, it
/// will normalize the escape sequences in [`"6\\/14\\/1946"`]() to [`"6/14/1946"`](),
/// because the escaped forward-slashes (`/`) are non-canonical.
/// 
/// Re-encoding instances of this type, including ``case number(_:)`` instances, through
/// multiple round trips will always produce output that is bytewise-identical to the
/// output of the first encoding iteration.
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
enum JSON:Sendable
{    
    /// A null value. 
    /// 
    /// The library models statically-typed null values elsewhere as
    /// [`Optional<Never>`]().
    case null 
    /// A boolean value. 
    case bool(Bool)
    /// A numerical value.
    case number(Number)
    /// A string value.
    /// 
    /// The contents of this string are *not* escaped. If you are creating an 
    /// instance of this type for serialization with this case-constructor, 
    /// do not escape the input.
    case string(String)
    /// An array container.
    case array(Array)
    /// An object container.
    case object(Object)
}
extension JSON
{
    /// Wraps a signed integer as a numeric value.
    /// 
    /// Calling this function is equivalent to the following:
    ///
    /// ```swift 
    /// let json:JSON = .number(JSON.Number.init(signed))
    /// ```
    @available(*, deprecated)
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
    @available(*, deprecated)
    @inlinable public static 
    func number<T>(_ unsigned:T) -> Self where T:UnsignedInteger 
    {
        .number(.init(unsigned))
    }
}
extension JSON
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
    /// >   Important: This function should *not* be called on an input to the ``string(_:)``
    ///     case  constructor. The library performs string escaping lazily; calling this
    ///     function explicitly will double-escape the input. 
    static 
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
}
extension JSON
{
    /// Attempts to parse a complete JSON message (either an ``Array`` or an 
    /// ``Object``) from a string.
    @inlinable public 
    init(parsing string:some StringProtocol) throws
    {
        try self.init(parsing: string.utf8)
    }
    /// Attempts to parse a complete JSON message (either an ``Array`` or an 
    /// ``Object``) from UTF-8-encoded text.
    @inlinable public 
    init<UTF8>(parsing utf8:UTF8) throws where UTF8:Collection<UInt8>
    {
        self = try JSON.Rule<UTF8.Index>.Root.parse(utf8)
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
        case .array(let array):
            return array.description
        case .object(let object):
            return object.description
        }
    }
}
extension JSON:ExpressibleByDictionaryLiteral 
{
    @inlinable public 
    init(dictionaryLiteral:(Key, Self)...) 
    {
        self = .object(.init(dictionaryLiteral))
    }
}
extension JSON:ExpressibleByArrayLiteral 
{
    @inlinable public 
    init(arrayLiteral:Self...) 
    {
        self = .array(.init(arrayLiteral))
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

extension JSON
{
    /// Promotes a `nil` result to a thrown ``TypecastError``.
    /// 
    /// If `T` conforms to ``JSONDecodable``, prefer calling its throwing
    /// ``JSONDecodable init(json:)`` to calling this method directly.
    ///
    /// >   Throws:
    ///     A ``TypecastError`` if the given closure returns [`nil`]().
    ///
    /// >   Complexity: O(1), as long as the closure is O(1).
    @inline(__always)
    @inlinable public 
    func cast<T>(with cast:(Self) throws -> T?) throws -> T
    {
        if let value:T = try cast(self)
        {
            return value 
        }
        else 
        {
            throw TypecastError<T>.init(invalid: self)
        }
    }
}

extension JSON
{
    /// Attempts to load an instance of ``Bool`` from this variant.
    /// 
    /// -   Returns:
    ///     The payload of this variant if it matches ``case bool(_:)``, 
    ///     [`nil`]() otherwise.
    ///
    /// >   Complexity: O(1).
    @inlinable public 
    func `as`(_:Bool.Type) -> Bool?
    {
        switch self 
        {
        case .bool(let bool):   return bool
        default:                return nil 
        }
    }

    /// Attempts to load an instance of some ``SignedInteger`` from this variant.
    /// 
    /// - Returns: A signed integer derived from the payload of this variant
    ///     if it matches ``case number(_:)``, and it can be represented exactly
    ///     by `T`; `nil` otherwise.
    ///
    /// This method reports failure in two ways — it returns `nil` on a type 
    /// mismatch, and it throws an ``IntegerOverflowError`` if this variant 
    /// matches ``case number(_:)``, but it could not be represented exactly by `T`.
    /// 
    /// >   Note:
    ///     This type conversion will fail if ``Number.places`` is non-zero, even if 
    ///     the fractional part is zero. For example, you can convert `5` to an
    ///     integer, but not `5.0`. This matches the behavior of
    ///     ``ExpressibleByIntegerLiteral``.
    ///
    /// >   Complexity: O(1).
    @inlinable public 
    func `as`<Integer>(_:Integer.Type) throws -> Integer? 
        where Integer:FixedWidthInteger & SignedInteger
    {
        // do not use init(exactly:) with decimal value directly, as this 
        // will also accept values like 1.0, which we want to reject
        guard case .number(let number) = self 
        else 
        {
            return nil
        }
        guard let integer:Integer = number.as(Integer.self)
        else 
        {
            throw IntegerOverflowError.init(number: number, overflows: Integer.self)
        }
        return integer 
    }
    /// Attempts to load an instance of some ``UnsignedInteger`` from this variant.
    /// 
    /// - Returns: An unsigned integer derived from the payload of this variant
    ///     if it matches ``case number(_:)``, and it can be represented exactly
    ///     by `T`; `nil` otherwise.
    ///
    /// This method reports failure in two ways — it returns `nil` on a type 
    /// mismatch, and it throws an ``IntegerOverflowError`` if this variant 
    /// matches ``case number(_:)``, but it could not be represented exactly by `T`.
    /// 
    /// >   Note:
    ///     This type conversion will fail if ``Number.places`` is non-zero, even if 
    ///     the fractional part is zero. For example, you can convert `5` to an
    ///     integer, but not `5.0`. This matches the behavior of
    ///     ``ExpressibleByIntegerLiteral``.
    ///
    /// >   Complexity: O(1).
    @inlinable public 
    func `as`<Integer>(_:Integer.Type) throws -> Integer?
        where Integer:FixedWidthInteger & UnsignedInteger
    {
        guard case .number(let number) = self 
        else 
        {
            return nil
        }
        guard let integer:Integer = number.as(Integer.self)
        else 
        {
            throw IntegerOverflowError.init(number: number, overflows: Integer.self)
        }
        return integer 
    }
    #if (os(Linux) || os(macOS)) && arch(x86_64)
    /// Attempts to load an instance of ``Float80`` from this variant.
    /// 
    /// -   Returns:
    ///     The closest value of ``Float80`` to the payload of this variant if it matches
    ///     ``case number(_:)``, `nil` otherwise.
    @inlinable public 
    func `as`(_:Float80.Type) -> Float80?
    {
        self.as(Number.self)?.as(Float80.self)
    }
    #endif
    /// Attempts to load an instance of ``Double`` from this variant.
    /// 
    /// -   Returns:
    ///     The closest value of ``Double`` to the payload of this variant if it matches
    ///     ``case number(_:)``, `nil` otherwise.
    @inlinable public 
    func `as`(_:Double.Type) -> Double?
    {
        self.as(Number.self)?.as(Double.self)
    }
    /// Attempts to load an instance of ``Float`` from this variant.
    /// 
    /// -   Returns:
    ///     The closest value of ``Float`` to the payload of this variant if it matches
    ///     ``case number(_:)``, `nil` otherwise.
    @inlinable public 
    func `as`(_:Float.Type) -> Float?
    {
        self.as(Number.self)?.as(Float.self)
    }
    /// Attempts to load an instance of ``Number`` from this variant.
    /// 
    /// -   Returns:
    ///     The payload of this variant, if it matches ``case number(_:)``,
    ///     `nil` otherwise.
    ///
    /// >   Complexity: O(1).
    @inlinable public 
    func `as`(_:Number.Type) -> Number?
    {
        switch self 
        {
        case .number(let number):   return number
        default:                    return nil 
        }
    }

    /// Attempts to load an instance of ``String`` from this variant.
    /// 
    /// -   Returns:
    ///     The payload of this variant, if it matches ``case string(_:)``,
    ///     `nil` otherwise.
    ///
    /// >   Complexity: O(1).
    @inlinable public 
    func `as`(_:String.Type) -> String?
    {
        switch self 
        {
        case .string(let string):   return string
        default:                    return nil 
        }
    }
}
extension JSON
{
    /// Attempts to load an explicit ``null`` from this variant.
    /// 
    /// -   Returns:
    ///     `nil` in the inner optional this variant is ``null``,
    //      `nil` in the outer optional otherwise.
    @inlinable public 
    func `as`(_:Never?.Type) -> Never??
    {
        switch self 
        {
        case .null: return (nil as Never?) as Never??
        default:    return  nil            as Never??
        }
    }
}
extension JSON
{
    /// Attempts to unwrap an array from this variant.
    /// 
    /// -   Returns:
    ///     The payload of this variant if it matches ``case array(_:)``,
    ///     `nil` otherwise.
    ///
    /// >   Complexity: O(1). This method does *not* perform any elementwise work.
    @inlinable public 
    var array:Array?
    {
        switch self 
        {
        case .array(let array): return array
        default:                return nil
        }
    }
    /// Attempts to unwrap an object from this variant.
    /// 
    /// - Returns: The payload of this variant if it matches ``case object(_:)``, 
    ///     the fields of the payload of this variant if it matches
    ///     ``case number(_:)``, or `nil` otherwise.
    /// 
    /// The order of the items reflects the order in which they appear in the 
    /// source object. For more details about the payload, see the documentation 
    /// for ``object(_:)``.
    /// 
    /// To facilitate interoperability with decimal types, this method will also 
    /// return a pseudo-object containing the values of ``Number.units`` and
    /// ``Number.places``, if this variant is a ``case number(_:)``. This function
    /// creates the pseudo-object by calling ``Object.init(encoding:)``.
    /// 
    /// >   Complexity: 
    ///     O(1). This method does *not* perform any elementwise work.
    @inlinable public 
    var object:Object? 
    {
        switch self 
        {
        case .object(let items):
            return items
        case .number(let number):
            return .init(encoding: number)
        default:
            return nil 
        }
    }
}
