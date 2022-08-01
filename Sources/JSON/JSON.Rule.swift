@_exported import Grammar

extension JSON 
{
    /// @import(Grammar)
    /// Matches a complete message; either an ``JSON/Rule//Array`` or an ``JSON/Rule//Object``.
    /// 
    /// All of the parsing rules in this library are defined at the UTF-8 level. 
    /// 
    /// To parse *any* JSON value, including fragment values, use the ``JSON/Rule//Value`` 
    /// rule instead.
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
    enum Rule<Location>:ParsingRule
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
        
        // @available(*, deprecated, renamed: "JSON.Rule")
        // public 
        // typealias Root = JSON.Rule<Location> 
        // public 
        // enum Root:ParsingRule
        // {
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
        // }
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