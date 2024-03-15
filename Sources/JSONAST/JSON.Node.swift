extension JSON
{
    @frozen public
    enum Node:Sendable
    {
        /// A null value.
        ///
        /// The library models statically-typed null values elsewhere as `Optional<Never>`.
        case null
        /// A boolean value.
        case bool(Bool)
        /// A string value.
        ///
        /// The contents of this string are *not* escaped.
        case string(Literal<String>)
        /// A numerical value.
        case number(Number)

        /// An array container.
        case array(Array)
        /// An object container.
        case object(Object)
    }
}

extension String
{
    init(_ literal:JSON.Literal<String>)
    {
        var json:JSON = .init(utf8: [])

        json.utf8.reserveCapacity(literal.value.utf8.count + 2)
        json += literal

        self.init(decoding: json.utf8, as: Unicode.UTF8.self)
    }
}

extension JSON.Node
{
    // TODO: optimize this, it should operate at the utf8 level, and be @inlinable

    /// Escapes and formats a string as a JSON string literal, including the
    /// beginning and ending quote characters. This function is used for debug reflection only;
    /// it is less efficient than the UTF-8 escaping implementation used by the encoder.
    ///
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
    // static
    // func escape<S>(_ string:S) -> String where S:StringProtocol
    // {
    //     var escaped:String = "\""
    //     for character:Character in string
    //     {
    //         switch character
    //         {
    //         case "\"":      escaped += "\\\""
    //         case "\\":      escaped += "\\\\"
    //         // slash escape is not mandatory, and does not improve legibility
    //         // case "/":       escaped += "\\/"
    //         case "\u{08}":  escaped += "\\b"
    //         case "\u{09}":  escaped += "\\t"
    //         case "\u{0A}":  escaped += "\\n"
    //         case "\u{0C}":  escaped += "\\f"
    //         case "\u{0D}":  escaped += "\\r"
    //         default:        escaped.append(character)
    //         }
    //     }
    //     escaped += "\""
    //     return escaped
    // }
}
extension JSON.Node:CustomStringConvertible
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
        case .null:                 "null"
        case .bool(true):           "true"
        case .bool(false):          "false"
        case .string(let literal):  .init(literal)
        case .number(let value):    value.description
        case .array(let array):     array.description
        case .object(let object):   object.description
        }
    }
}
extension JSON.Node:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(JSON.Key, Self)...)
    {
        self = .object(.init(dictionaryLiteral))
    }
}
extension JSON.Node:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Self...)
    {
        self = .array(.init(arrayLiteral))
    }
}
extension JSON.Node:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self = .string(JSON.Literal<String>.init(stringLiteral))
    }
}
extension JSON.Node:ExpressibleByBooleanLiteral
{
    @inlinable public
    init(booleanLiteral:Bool)
    {
        self = .bool(booleanLiteral)
    }
}

extension JSON.Node
{
    /// Promotes a `nil` result to a thrown ``TypecastError``.
    ///
    /// If `T` conforms to ``JSONDecodable``, prefer calling its throwing
    /// ``JSONDecodable/init(json:)`` to calling this method directly.
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
            throw JSON.TypecastError<T>.init(invalid: self)
        }
    }
}

extension JSON.Node
{
    /// Attempts to load an instance of ``Bool`` from this variant.
    ///
    /// -   Returns:
    ///     The payload of this variant if it matches ``bool(_:) [case]``,
    ///     [`nil`]() otherwise.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    func `as`(_:Bool.Type) -> Bool?
    {
        switch self
        {
        case .bool(let bool):   bool
        default:                nil
        }
    }

    /// Attempts to load an instance of some ``SignedInteger`` from this variant.
    ///
    /// - Returns: A signed integer derived from the payload of this variant
    ///     if it matches ``number(_:) [case]``, and it can be represented exactly
    ///     by `T`; `nil` otherwise.
    ///
    /// This method reports failure in two ways — it returns `nil` on a type
    /// mismatch, and it throws an ``IntegerOverflowError`` if this variant
    /// matches ``number(_:) [case]``, but it could not be represented exactly by `T`.
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
            throw JSON.IntegerOverflowError.init(number: number, overflows: Integer.self)
        }
        return integer
    }
    /// Attempts to load an instance of some ``UnsignedInteger`` from this variant.
    ///
    /// - Returns: An unsigned integer derived from the payload of this variant
    ///     if it matches ``number(_:) [case]``, and it can be represented exactly
    ///     by `T`; `nil` otherwise.
    ///
    /// This method reports failure in two ways — it returns `nil` on a type
    /// mismatch, and it throws an ``IntegerOverflowError`` if this variant
    /// matches ``number(_:) [case]``, but it could not be represented exactly by `T`.
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
            throw JSON.IntegerOverflowError.init(number: number, overflows: Integer.self)
        }
        return integer
    }
    #if (os(Linux) || os(macOS)) && arch(x86_64)
    /// Attempts to load an instance of ``Float80`` from this variant.
    ///
    /// -   Returns:
    ///     The closest value of ``Float80`` to the payload of this variant if it matches
    ///     ``number(_:) [case]``, `nil` otherwise.
    @inlinable public
    func `as`(_:Float80.Type) -> Float80?
    {
        self.as(JSON.Number.self)?.as(Float80.self)
    }
    #endif
    /// Attempts to load an instance of ``Double`` from this variant.
    ///
    /// -   Returns:
    ///     The closest value of ``Double`` to the payload of this variant if it matches
    ///     ``number(_:) [case]``, `nil` otherwise.
    @inlinable public
    func `as`(_:Double.Type) -> Double?
    {
        self.as(JSON.Number.self)?.as(Double.self)
    }
    /// Attempts to load an instance of ``Float`` from this variant.
    ///
    /// -   Returns:
    ///     The closest value of ``Float`` to the payload of this variant if it matches
    ///     ``number(_:) [case]``, `nil` otherwise.
    @inlinable public
    func `as`(_:Float.Type) -> Float?
    {
        self.as(JSON.Number.self)?.as(Float.self)
    }
    /// Attempts to load an instance of ``Number`` from this variant.
    ///
    /// -   Returns:
    ///     The payload of this variant, if it matches ``number(_:) [case]``,
    ///     `nil` otherwise.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    func `as`(_:JSON.Number.Type) -> JSON.Number?
    {
        switch self
        {
        case .number(let number):   number
        default:                    nil
        }
    }

    /// Attempts to load an instance of ``String`` from this variant.
    ///
    /// -   Returns:
    ///     The payload of this variant, if it matches ``string(_:) [case]``,
    ///     `nil` otherwise.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    func `as`(_:String.Type) -> String?
    {
        switch self
        {
        case .string(let string):   string.value
        default:                    nil
        }
    }
}
extension JSON.Node
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
        case .null: (nil as Never?) as Never??
        default:    nil            as Never??
        }
    }
}
extension JSON.Node
{
    /// Attempts to unwrap an array from this variant.
    ///
    /// -   Returns:
    ///     The payload of this variant if it matches ``array(_:) [case]``,
    ///     `nil` otherwise.
    ///
    /// >   Complexity: O(1). This method does *not* perform any elementwise work.
    @inlinable public
    var array:JSON.Array?
    {
        switch self
        {
        case .array(let array): array
        default:                nil
        }
    }
    /// Attempts to unwrap an object from this variant.
    ///
    /// - Returns: The payload of this variant if it matches ``object(_:) [case]``,
    ///     the fields of the payload of this variant if it matches
    ///     ``number(_:) [case]``, or `nil` otherwise.
    ///
    /// The order of the items reflects the order in which they appear in the
    /// source object. For more details about the payload, see the documentation
    /// for ``object(_:)``.
    ///
    /// To facilitate interoperability with decimal types, this method will also
    /// return a pseudo-object containing the values of ``Number.units`` and
    /// ``Number.places``, if this variant is a ``number(_:) [case]``. This function
    /// creates the pseudo-object by calling ``Object.init(encoding:)``.
    ///
    /// >   Complexity:
    ///     O(1). This method does *not* perform any elementwise work.
    @inlinable public
    var object:JSON.Object?
    {
        switch self
        {
        case .object(let items):
            items
        case .number(let number):
            .init(encoding: number)
        default:
            nil
        }
    }
}
