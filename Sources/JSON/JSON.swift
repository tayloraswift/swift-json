<<<<<<< HEAD
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
=======
@_exported import Grammar

extension JSON 
{
    public static
    func _break(_ json:[UInt8]) throws -> [Range<Int>]
    {
        var input:ParsingInput<Grammar.NoDiagnostics<[UInt8]>> = .init(json)
        var indices:[Range<Int>]    = []
        var start:Int               = input.index 
        while let _:Self = input.parse(as: Rule<Int>.Root?.self)
        {
            indices.append(start ..< input.index)
            start = input.index
        }
        return indices 
    }

    /// @import(Grammar)
    /// A generic context for structured parsing rules.
    /// 
    /// All of the parsing rules in this library are defined at the UTF-8 level. 
    /// 
    /// You can parse JSON expressions from any ``Collection`` with an 
    /// ``Collection//Element`` type of ``UInt8``. For example, you can parse 
    /// a ``String`` through its ``String//UTF8View``.
    /**
    ```swift 
    let string:String = 
    """
    {"success":true,"value":0.1}
    """
    try Grammar.parse(string.utf8, as: JSON.Rule<String.Index>.Root.self)
    ```
    */
    /// However, you could also parse a UTF-8 buffer directly, without 
    /// having to convert it to a ``String``.
    /**
    ```swift 
    let utf8:[UInt8] = 
    [
        123,  34, 115, 117,  99,  99, 101, 115, 
        115,  34,  58, 116, 114, 117, 101,  44, 
         34, 118,  97, 108, 117, 101,  34,  58, 
         48,  46,  49, 125
    ]
    try Grammar.parse(utf8, as: JSON.Rule<Array<UInt8>.Index>.Root.self)
    ```
    */
    /// The generic [`Location`]() 
    /// parameter provides this flexibility as a zero-cost abstraction.
    /// 
    /// >   Tip: 
    ///     The ``/swift-grammar`` and ``/swift-json`` libraries are transparent!
    ///     This means that its parsing rules are always zero-cost abstractions, 
    ///     even when applied to third-party collection types, like 
    ///     ``/swift-nio/NIOCore/ByteBufferView``.
    public 
    enum Rule<Location> 
    {
        /// ASCII terminals.
        public 
        typealias ASCII = Grammar.Encoding<Location, UInt8>
        /// ASCII hexadecimal digit terminals.
        public 
        typealias HexDigit<T> = Grammar.HexDigit<Location, UInt8, T> where T:BinaryInteger
        /// ASCII decimal digit terminals.
        public 
        typealias DecimalDigit<T> = Grammar.DecimalDigit<Location, UInt8, T> where T:BinaryInteger
    }
}
extension JSON.Rule 
{
    /// A literal `null` expression.
    public 
    enum Null:LiteralRule 
    {
        public 
        typealias Terminal = UInt8 
        /// The ASCII string [`"null"`]().
        @inlinable public static 
        var literal:[UInt8] 
        { 
            [0x6e, 0x75, 0x6c, 0x6c]
        }
    }
    /// A literal `true` expression.
    public 
    enum True:LiteralRule 
    {
        public 
        typealias Terminal = UInt8 
        /// The ASCII string [`"true"`]().
        @inlinable public static 
        var literal:[UInt8] 
        { 
            [0x74, 0x72, 0x75, 0x65]
        }
    }
    /// A literal `false` expression.
    public 
    enum False:LiteralRule 
    {
        public 
        typealias Terminal = UInt8 
        /// The ASCII string [`"false"`]().
        @inlinable public static 
        var literal:[UInt8] 
        { 
            [0x66, 0x61, 0x6c, 0x73, 0x65]
        }
    }
    
    @available(*, deprecated, message: "nested types have been moved into the outer `JSON` namespace.")
    public 
    enum Keyword
    {
        @available(*, deprecated, renamed: "JSON.Null")
        public 
        typealias Null = JSON.Rule<Location>.Null
        @available(*, deprecated, renamed: "JSON.True")
        public 
        typealias True = JSON.Rule<Location>.True
        @available(*, deprecated, renamed: "JSON.False")
        public 
        typealias False = JSON.Rule<Location>.False
    }
    
    /// Matches a complete message; either an ``JSON/Rule//Array`` or an ``JSON/Rule//Object``.
    /// 
    /// To parse *any* JSON value, including fragment values, use the ``JSON/Rule//Value`` 
    /// rule instead.
    public 
    enum Root:ParsingRule 
    {
        public 
        typealias Terminal = UInt8
        @inlinable public static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> JSON
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            if let items:[(key:String, value:JSON)] = input.parse(as: Object?.self)
            {
                return .object(items)
            }
            else 
            {
                return .array(try input.parse(as: Array.self))
            }
        }
    }
    /// Matches any value, including fragment values.
    /// 
    /// Only use this if you are doing manual JSON parsing. Most web services 
    /// should send complete ``JSON/Rule//Root`` messages through their public APIs.
    public 
    enum Value:ParsingRule
    {
        public 
        typealias Terminal = UInt8
        @inlinable public static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> JSON
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            if let number:JSON.Number = input.parse(as: NumberLiteral?.self)
            {
                return .number(number)
            }
            else if let string:String = input.parse(as: StringLiteral?.self)
            {
                return .string(string)
            }
            else if let elements:[JSON] = input.parse(as: Array?.self)
            {
                return .array(elements)
            }
            else if let items:[(key:String, value:JSON)] = input.parse(as: Object?.self)
            {
                return .object(items)
            }
            else if let _:Void = input.parse(as: True?.self)
            {
                return .bool(true)
            }
            else if let _:Void = input.parse(as: False?.self)
            {
                return .bool(false)
            }
            else
            {
                try input.parse(as: Null.self)
                return .null 
            }
        }
    }
    /// Matches a numeric literal. 
    /// 
    /// Numeric literals are always written in decimal.
    /// 
    /// The following examples are all valid literals:
    /** 
    ```swift 
    "5"
    "5.5"
    "-5.5"
    "-55e-2"
    "-55e2"
    "-55e+2"
    ```
    */
    /// Numeric literals may not begin with a prefix `+` sign, although the 
    /// exponent field can use a prefix `+`.
    public 
    enum NumberLiteral:ParsingRule
    {
        /// Matches an ASCII `+` or `-` sign.
        public 
        enum PlusOrMinus:TerminalRule 
        {
            public 
            typealias Terminal      = UInt8
            public 
            typealias Construction  = FloatingPointSign
            @inlinable public static 
            func parse(terminal:UInt8) -> FloatingPointSign? 
            {
                switch terminal 
                {
                case 0x2b:  return .plus 
                case 0x2d:  return .minus
                default:    return nil
                }
            }
        }
        public 
        typealias Terminal = UInt8
        @inlinable public static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> JSON.Number
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            // https://datatracker.ietf.org/doc/html/rfc8259#section-6
            // JSON does not allow prefix '+'
            let sign:FloatingPointSign
            switch input.parse(as: ASCII.Minus?.self)
            {
            case  _?:   sign = .minus 
            case nil:   sign = .plus
            }
            
            var units:UInt64    = 
                try  input.parse(as: Grammar.UnsignedIntegerLiteral<DecimalDigit<UInt64>>.self)
            var places:UInt32   = 0
            if  var (_, remainder):(Void, UInt64) = 
                try? input.parse(as: (ASCII.Period, DecimalDigit<UInt64>).self)
            {
                while true 
                {
                    guard   case (let shifted, false) = units.multipliedReportingOverflow(by: 10), 
                            case (let refined, false) = shifted.addingReportingOverflow(remainder)
                    else 
                    {
                        throw Grammar.IntegerOverflowError<UInt64>.init()
                    }
                    places += 1
                    units   = refined
                    
                    guard let next:UInt64 = input.parse(as: DecimalDigit<UInt64>?.self)
                    else 
                    {
                        break 
                    }
                    remainder = next
                }
            }
            if  let _:Void                  =     input.parse(as: ASCII.E?.self) 
            {
                let sign:FloatingPointSign? =     input.parse(as: PlusOrMinus?.self)
                let exponent:UInt32         = try input.parse(as: Grammar.UnsignedIntegerLiteral<DecimalDigit<UInt32>>.self)
                // you too, can exploit the vulnerabilities below
                switch sign
                {
                case .minus?:
                    places         += exponent 
                case .plus?, nil:
                    guard places    < exponent
                    else 
                    {
                        places     -= exponent
                        break 
                    }
                    defer 
                    {
                        places      = 0
                    }
                    guard units    != 0 
                    else 
                    {
                        break 
                    }
                    let shift:Int   = .init(exponent - places) 
                    guard shift     < JSON.Base10.Exp.endIndex, case (let shifted, false) = 
                        units.multipliedReportingOverflow(by: JSON.Base10.Exp[shift])
                    else 
                    {
                        throw Grammar.IntegerOverflowError<UInt64>.init()
                    }
                    units           = shifted
                }
            }
            return .init(sign: sign, units: units, places: places)
        }
    }
    /// Matches a string literal. 
    /// 
    /// String literals always begin and end with an ASCII double quote character (`"`).
    public 
    enum StringLiteral:ParsingRule 
    {
        /// Matches a UTF-8 code unit that is allowed to appear inline in a string literal. 
        public 
        enum CodeUnit:TerminalRule
        {
            @available(*, deprecated, renamed: "JSON.Rule.CodeUnit")
            public 
            typealias Unescaped = Self
            @available(*, deprecated, renamed: "JSON.Rule.EscapedCodeUnit")
            public 
            typealias Escaped = EscapedCodeUnit
            
            public 
            typealias Terminal      = UInt8
            public 
            typealias Construction  = Void 
            @inlinable public static 
            func parse(terminal:UInt8) -> Void? 
            {
                switch terminal 
                {
                case 0x20 ... 0x21, 0x23 ... 0x5b, 0x5d ... 0xff:
                    return () 
                default:
                    return nil
                }
            }
        } 
        /// Matches an ASCII character (besides [`"u"`]()) that is allowed to 
        /// appear immediately after a backslash (`\`) in a string literal.
        /// 
        /// The following are valid escape characters: `\`, `"`, `/`, `b`, `f`, `n`, `r`, `t`.
        public 
        enum EscapedCodeUnit:TerminalRule 
        {
            public 
            typealias Terminal      = UInt8
            public 
            typealias Construction  = Unicode.Scalar 
            @inlinable public static 
            func parse(terminal:UInt8) -> Unicode.Scalar? 
            {
                switch terminal
                {
                // '\\', '\"', '\/'
                case 0x5c, 0x22, 0x2f:
                            return .init(terminal) 
                case 0x62:  return "\u{08}" // '\b'
                case 0x66:  return "\u{0C}" // '\f'
                case 0x6e:  return "\u{0A}" // '\n'
                case 0x72:  return "\u{0D}" // '\r'
                case 0x74:  return "\u{09}" // '\t'
                default:    return nil 
                }
            }
        }
        /// Matches a sequence of escaped UTF-16 code units.
        /// 
        /// A UTF-16 escape sequence consists of [`"\u"`](), followed by four 
        /// hexadecimal digits.
        public 
        enum EscapeSequence:ParsingRule 
        {
            public 
            typealias Terminal = UInt8
            @inlinable public static 
            func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> String
                where   Diagnostics:ParsingDiagnostics,
                        Diagnostics.Source.Index == Location,
                        Diagnostics.Source.Element == Terminal
            {
                try input.parse(as: ASCII.Backslash.self)
                var unescaped:String = ""
                while true  
                {
                    if let scalar:Unicode.Scalar = input.parse(as: EscapedCodeUnit?.self)
                    {
                        unescaped.append(Character.init(scalar))
                    }
                    else 
                    {
                        try input.parse(as: ASCII.U.Lowercase.self) 
                        let value:UInt16 = 
                            (try input.parse(as: HexDigit<UInt16>.self) << 12) |
                            (try input.parse(as: HexDigit<UInt16>.self) <<  8) |
                            (try input.parse(as: HexDigit<UInt16>.self) <<  4) |
                            (try input.parse(as: HexDigit<UInt16>.self)) 
                        if let scalar:Unicode.Scalar = Unicode.Scalar.init(value)
                        {
                            unescaped.append(Character.init(scalar))
                        }
                        else 
                        {
                            throw JSON.InvalidUnicodeScalarError.init(value: value)
                        }
                    }
                    
                    guard case _? = input.parse(as: ASCII.Backslash?.self)
                    else 
                    {
                        break 
                    }
                }
                return unescaped
            }
        }
        public 
        typealias Terminal = UInt8
        @inlinable public static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> String
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            try                 input.parse(as: ASCII.Quote.self)
            
            let start:Location      = input.index 
            input.parse(as: CodeUnit.self, in: Void.self)
            let end:Location        = input.index 
            var string:String       = .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
            
            while let next:String   = input.parse(as: EscapeSequence?.self)
            {
                string             += next 
                let start:Location  = input.index 
                input.parse(as: CodeUnit.self, in: Void.self)
                let end:Location    = input.index 
                string             += .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
            }
            
            try                 input.parse(as: ASCII.Quote.self)
            return string 
        }
    }
    /// @import(Grammar)
    /// Matches the whitespace characters [`" "`](), [`"\t"`](), 
    /// [`"\n"`](), and [`"\r"`]().
    /// 
    /// This rule matches a *single* whitespace character.
    /// To match a sequence of whitespace characters (including the empty sequence), 
    /// use one of ``/swift-grammar``’s vector parsing APIs, like ``ParsingInput.parse(as:in:)``.
    /// 
    /// For example, the following is equivalent to the regex [`/[\ \t\n\r]+/`]():
    /**
    ```swift 
    try input.parse(as: JSON.Rule<Location>.Whitespace.self)
        input.parse(as: JSON.Rule<Location>.Whitespace.self, in: Void.self)
    ```
    */
    /// >   Note: Unicode space characters, like [`"\u{2009}"`](), are not 
    ///     considered whitespace characters in the context of JSON parsing.
    public 
    enum Whitespace:TerminalRule 
    {
        public 
        typealias Terminal      = UInt8
        public 
        typealias Construction  = Void 
        @inlinable public static 
        func parse(terminal:UInt8) -> Void? 
        {
            switch terminal 
            {
            case    0x20, // ' '
                    0x09, // '\t'
                    0x0a, // '\n'
                    0x0d: // '\r'
                return ()
            default:
                return nil
            }
        }
    }
    /// A helper rule, which accepts an input sequence that matches [`Rule`](), 
    /// with optional leading and trailing ``Whitespace`` characters.
    public 
    typealias Padded<Rule> = Grammar.Pad<Rule, Whitespace> 
        where Rule:ParsingRule, Rule.Location == Location, Rule.Terminal == UInt8
    
    /// @import(Grammar)
    /// Matches an array literal.
    /// 
    /// Array literals begin and end with square brackets (`[` and `]`), and 
    /// recursively contain instances of ``JSON/Rule//Value`` separated by ``JSON/Rule//Padded`` 
    /// ``Grammar/Encoding//Comma``s. Trailing commas are not allowed.
    public  
    enum Array:ParsingRule 
    {
        public 
        typealias Terminal = UInt8
        @inlinable public static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> [JSON]
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            try input.parse(as: Padded<ASCII.BracketLeft>.self)
            var elements:[JSON]
            if let head:JSON = try? input.parse(as: Value.self)
            {
                elements = [head]
                while let (_, next):(Void, JSON) = try? input.parse(as: (Padded<ASCII.Comma>, Value).self)
                {
                    elements.append(next)
                }
            }
            else 
            {
                elements = []
            }
            try input.parse(as: Padded<ASCII.BracketRight>.self)
            return elements
        }
    }
    /// @import(Grammar)
    /// Matches an object literal.
    /// 
    /// Object literals begin and end with curly braces (`{` and `}`), and 
    /// contain instances of ``Item`` separated by ``JSON/Rule//Padded`` 
    /// ``Grammar/Encoding//Comma``s. Trailing commas are not allowed.
    public 
    enum Object:ParsingRule 
    {
        /// @import(Grammar)
        /// Matches an key-value expression.
        /// 
        /// A key-value expression consists of a ``JSON/Rule//StringLiteral``, 
        /// a ``JSON/Rule//Padded`` ``Grammar/Encoding//Colon``, and 
        /// a recursive instance of ``JSON/Rule//Value``.
        public 
        enum Item:ParsingRule 
        {
            public 
            typealias Terminal = UInt8
            @inlinable public static 
            func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> (key:String, value:JSON)
                where   Diagnostics:ParsingDiagnostics,
                        Diagnostics.Source.Index == Location,
                        Diagnostics.Source.Element == Terminal
            {
                let key:String  = try input.parse(as: StringLiteral.self)
                try input.parse(as: Padded<ASCII.Colon>.self)
                let value:JSON  = try input.parse(as: Value.self)
                return (key, value)
            }
        }
        public 
        typealias Terminal = UInt8
        @inlinable public static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> [(key:String, value:JSON)]
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            try input.parse(as: Padded<ASCII.BraceLeft>.self)
            var items:[(key:String, value:JSON)]
            if let head:(key:String, value:JSON) = try? input.parse(as: Item.self)
            {
                items = [head]
                while let (_, next):(Void, (key:String, value:JSON)) = try? input.parse(as: (Padded<ASCII.Comma>, Item).self)
                {
                    items.append(next)
                }
            }
            else 
            {
                items = []
            }
            try input.parse(as: Padded<ASCII.BraceRight>.self)
            return items
        }
    }
}
>>>>>>> master
