@_exported import Grammar

#if swift(>=5.5)
extension JSON:Sendable {}
extension JSON.Number:Sendable {}
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
    
    /// A lossless representation of a numeric literal.
    ///
    /// This type can store fixed-point numbers with up to 64 bits of precision.
    /// It uses all 64 bits to encode its magnitude, which enables it to round-trip
    /// integers of width up to ``UInt64``.
    @frozen public 
    struct Number:CustomStringConvertible
    {
        // this layout should allow instances of `Number` to fit in 2 words
        
        // this is backed by an `Int`, but the swift compiler can optimize it 
        // into a `UInt8`-sized field
        
        /// The sign of this numeric literal.
        public 
        var sign:FloatingPointSign 
        // cannot have an inlinable property wrapper
        public 
        var _places:UInt32
        /// The number of decimal places this numeric literal has.
        /// 
        /// >   Note:
        /// >   This property has type ``UInt64`` to facilitate computations with 
        ///     ``units``. It is backed by a ``UInt32`` and can therefore only store 
        ///     32 bits of precision.
        @inlinable public 
        var places:UInt64 
        {
            .init(self._places)
        }
        /// The magnitude of this numeric literal, expressed in units of ``places``.
        /// 
        /// If ``units`` is [`123`](), and ``places`` is [`2`](), that would represent
        /// a magnitude of [`1.23`]().
        public 
        var units:UInt64
        /// Creates a numeric literal.
        /// -   Parameters:
        ///     - sign: The sign, positive or negative.
        ///     - units: The magnitude, in units of `places`.
        ///     - places: The number of decimal places.
        @inlinable public
        init(sign:FloatingPointSign, units:UInt64, places:UInt32)
        {
            self.sign       = sign 
            self.units      = units 
            self._places    = places
        }
        /// Returns a zero-padded string representation of this numeric literal. 
        /// 
        /// This property always formats the number with full precision. 
        /// If ``units`` is [`100`]() and ``places`` is [`2`](), this will return 
        /// [`"1.00"`]().
        /// 
        /// This string is guaranteed to be round-trippable; reparsing it 
        /// will always return the same value.
        ///
        /// >   Warning:
        /// >   This string is not necessarily identical to how this literal was 
        ///     written in its original source file. In particular, if it was 
        ///     written with an exponent, the exponent would have been normalized 
        ///     into ``units`` and ``places``.
        public 
        var description:String
        {
            guard self.places > 0 
            else 
            {
                switch self.sign 
                {
                case .plus:     return  "\(self.units)"
                case .minus:    return "-\(self.units)"
                }
            }
            let places:Int      = .init(self.places)
            let unpadded:String = .init(self.units)
            let string:String   = "\(String.init(repeating: "0", count: Swift.max(0, 1 + places - unpadded.count)))\(unpadded)"
            switch self.sign 
            {
            case .plus:     return  "\(string.dropLast(places)).\(string.suffix(places))"
            case .minus:    return "-\(string.dropLast(places)).\(string.suffix(places))"
            }
        }
        @available(*, deprecated, renamed: "JS")
        public
        func callAsFunction<T>(as _:T?.Type) -> T? where T:FixedWidthInteger & UnsignedInteger 
        {
            self.as(T.self)
        }
        @available(*, deprecated, renamed: "JSON.Number.as(_:)")
        public
        func callAsFunction<T>(as _:T?.Type) -> T? where T:FixedWidthInteger & SignedInteger 
        {
            self.as(T.self)
        }
        @available(*, deprecated, renamed: "JSON.Number.as(_:)")
        public
        func callAsFunction<T>(as _:(units:T, places:T)?.Type) -> (units:T, places:T)? 
            where T:FixedWidthInteger & SignedInteger 
        {
            self.as((units:T, places:T).self)
        }
        @available(*, deprecated, renamed: "JSON.Number.as(_:)")
        public
        func callAsFunction<T>(as _:T.Type) -> T where T:BinaryFloatingPoint
        {
            self.as(T.self)
        }
        /// Converts this numeric literal to an unsigned integer, if it can be 
        /// represented exactly.
        /// -   Parameters:
        ///     - _: A type conforming to ``UnsignedInteger`` (and ``FixedWidthInteger``).
        /// -   Returns: 
        ///     The value of this numeric literal as an instance of [`T`](), or 
        ///     [`nil`]() if it is negative, fractional, or would overflow [`T`]().
        @inlinable public
        func `as`<T>(_:T.Type) -> T? where T:FixedWidthInteger & UnsignedInteger 
        {
            guard self.places == 0
            else 
            {
                return nil 
            }
            switch self.sign 
            {
            case .minus: 
                return self.units == 0 ? 0 : nil 
            case .plus: 
                return T.init(exactly: self.units)
            }
        }
        /// Converts this numeric literal to a signed integer, if it can be 
        /// represented exactly.
        /// -   Parameters:
        ///     - _: A type conforming to ``SignedInteger`` (and ``FixedWidthInteger``).
        /// -   Returns: 
        ///     The value of this numeric literal as an instance of [`T`](), or 
        ///     [`nil`]() if it is fractional or would overflow [`T`]().
        @inlinable public
        func `as`<T>(_:T.Type) -> T? where T:FixedWidthInteger & SignedInteger 
        {
            guard self.places == 0
            else 
            {
                return nil 
            }
            switch self.sign 
            {
            case .minus: 
                let negated:Int64   = .init(bitPattern: 0 &- self.units)
                return negated     <= 0 ? T.init(exactly: negated) : nil
            case .plus: 
                return                    T.init(exactly: self.units)
            }
        }
        /// Converts this numeric literal to a fixed-point decimal, if it can be 
        /// represented exactly.
        /// -   Parameters:
        ///     - _: A tuple type with fields conforming to ``SignedInteger`` 
        ///         (and ``FixedWidthInteger``).
        /// -   Returns: 
        ///     The value of this numeric literal as an instance of 
        ///     [`(units:T, places:T)`](), or [`nil`]() if the value of either 
        ///     field would overflow [`T`]().
        @inlinable public
        func `as`<T>(_:(units:T, places:T).Type) -> (units:T, places:T)? 
            where T:FixedWidthInteger & SignedInteger 
        {
            guard let places:T      = T.init(exactly: self.places)
            else 
            {
                return nil
            }
            switch self.sign 
            {
            case .minus: 
                let negated:Int64   = Int64.init(bitPattern: 0 &- self.units)
                guard negated      <= 0, 
                    let units:T     = T.init(exactly: negated)
                else 
                {
                    return nil 
                }
                return (units: units, places: places)
            case .plus: 
                guard let units:T   = T.init(exactly: self.units)
                else 
                {
                    return nil 
                }
                return (units: units, places: places)
            }
        }
        /// Converts this numeric literal to a floating-point value, or its closest 
        /// floating-point representation.
        /// -   Parameters:
        ///     - _: A type conforming to ``BinaryFloatingPoint``.
        /// -   Returns: 
        ///     The value of this numeric literal as an instance of 
        ///     [`T`](), or the value of [`T`]() closest to it.
        @inlinable public
        func `as`<T>(_:T.Type) -> T where T:BinaryFloatingPoint 
        {
            var places:Int      = .init(self.places), 
                units:UInt64    =       self.units 
            // steve canon, feel free to submit a PR
            while places > 0 
            {
                guard case (let quotient, remainder: 0) = units.quotientAndRemainder(dividingBy: 10)
                else 
                {
                    switch self.sign 
                    {
                    case .minus: return -T.init(units) * Base10.Inverse[places, as: T.self]
                    case  .plus: return  T.init(units) * Base10.Inverse[places, as: T.self]
                    }
                }
                units   = quotient
                places -= 1
            }
            switch self.sign 
            {
            case .minus: return -T.init(units)
            case  .plus: return  T.init(units)
            }
        }
    }
    /// A namespace for decimal-related functionality.
    /// 
    /// This API is used by library functions that are emitted into the client. 
    /// Most users of ``/swift-json`` should not have to call it directly.
    public 
    enum Base10
    {
        /// Positive powers of 10, up to [`10_000_000_000_000_000_000`]().
        public static
        let Exp:[UInt64] = 
        [
            1, 
            10, 
            100, 
            
            1_000,
            10_000, 
            100_000, 
            
            1_000_000, 
            10_000_000,
            100_000_000,
            
            1_000_000_000, 
            10_000_000_000,
            100_000_000_000,
            
            1_000_000_000_000, 
            10_000_000_000_000,
            100_000_000_000_000,
            
            1_000_000_000_000_000, 
            10_000_000_000_000_000,
            100_000_000_000_000_000,
            
            1_000_000_000_000_000_000, 
            10_000_000_000_000_000_000,
            //  UInt64.max: 
            //  18_446_744_073_709_551_615
        ]
        /// Negative powers of 10, down to [`1e-19`]().
        public 
        enum Inverse 
        {
            /// Returns the inverse of the given power of 10.
            /// -   Parameters:
            ///     - x: A positive exponent. If `x` is [`2`](), this subscript 
            ///         will return [`1e-2`]().
            ///     - _: A ``BinaryFloatingPoint`` type.
            @inlinable public static 
            subscript<T>(x:Int, as _:T.Type) -> T 
                where T:BinaryFloatingPoint
            {
                let inverses:[T] = 
                [
                    1, 
                    1e-1, 
                    1e-2, 
                    
                    1e-3,
                    1e-4, 
                    1e-5, 
                    
                    1e-6, 
                    1e-7,
                    1e-8,
                    
                    1e-9, 
                    1e-10,
                    1e-11,
                    
                    1e-12, 
                    1e-13,
                    1e-14,
                    
                    1e-15, 
                    1e-16,
                    1e-17,
                    
                    1e-18, 
                    1e-19,
                ]
                return inverses[x]
            }
        }
    }
    
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
    /// not be confused with [`nil`]() in Swift.
    case null 
    /// A boolean value. 
    case bool(Bool)
    /// A numerical value.
    case number(Number)
    /// A string value.
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
    case object([(key:String, value:Self)])
}

extension JSON 
{
    /// A generic context for ``Grammar/ParsingRule``s.
    public 
    enum Rule<Location> 
    {
        public 
        typealias ASCII     = Grammar.Encoding<Location, UInt8>.ASCII
        public 
        typealias Digit<T>  = Grammar.Digit<Location, UInt8, T>.ASCII where T:BinaryInteger
    }
}
extension JSON.Rule 
{
    public 
    enum Keyword
    {
        public 
        enum Null:Grammar.TerminalSequence 
        {
            public 
            typealias Terminal = UInt8 
            @inlinable public static 
            var literal:[UInt8] 
            { 
                [0x6e, 0x75, 0x6c, 0x6c]
            }
        }
        public 
        enum True:Grammar.TerminalSequence 
        {
            public 
            typealias Terminal = UInt8 
            @inlinable public static 
            var literal:[UInt8] 
            { 
                [0x74, 0x72, 0x75, 0x65]
            }
        }
        public 
        enum False:Grammar.TerminalSequence 
        {
            public 
            typealias Terminal = UInt8 
            @inlinable public static 
            var literal:[UInt8] 
            { 
                [0x66, 0x61, 0x6c, 0x73, 0x65]
            }
        }
    }
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
            else if let _:Void = input.parse(as: Keyword.True?.self)
            {
                return .bool(true)
            }
            else if let _:Void = input.parse(as: Keyword.False?.self)
            {
                return .bool(false)
            }
            else
            {
                try input.parse(as: Keyword.Null.self)
                return .null 
            }
        }
    }
    
    public 
    enum NumberLiteral:ParsingRule
    {
        public 
        enum PlusOrMinus:Grammar.TerminalClass 
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
                try  input.parse(as: Grammar.UnsignedIntegerLiteral<Digit<UInt64>.Decimal>.self)
            var places:UInt32   = 0
            if  var (_, remainder):(Void, UInt64) = 
                try? input.parse(as: (ASCII.Period, Digit<UInt64>.Decimal).self)
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
                    
                    guard let next:UInt64 = input.parse(as: Digit<UInt64>.Decimal?.self)
                    else 
                    {
                        break 
                    }
                    remainder = next
                }
            }
            if  let _:Void                  =     input.parse(as: ASCII.E.Anycase?.self) 
            {
                let sign:FloatingPointSign? =     input.parse(as: PlusOrMinus?.self)
                let exponent:UInt32         = try input.parse(as: Grammar.UnsignedIntegerLiteral<Digit<UInt32>.Decimal>.self)
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
    public 
    enum StringLiteral:ParsingRule 
    {
        public 
        enum CodeUnit 
        {
            public 
            enum Unescaped:Grammar.TerminalClass
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
                    case 0x20 ... 0x21, 0x23 ... 0x5b, 0x5d ... 0xff:
                        return () 
                    default:
                        return nil
                    }
                }
            } 
            public 
            enum Escaped:Grammar.TerminalClass 
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
        }
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
                    if let scalar:Unicode.Scalar = input.parse(as: CodeUnit.Escaped?.self)
                    {
                        unescaped.append(Character.init(scalar))
                    }
                    else 
                    {
                        try input.parse(as: ASCII.U.Lowercase.self) 
                        let value:UInt16 = 
                            (try input.parse(as: Digit<UInt16>.Hex.Anycase.self) << 12) |
                            (try input.parse(as: Digit<UInt16>.Hex.Anycase.self) <<  8) |
                            (try input.parse(as: Digit<UInt16>.Hex.Anycase.self) <<  4) |
                            (try input.parse(as: Digit<UInt16>.Hex.Anycase.self)) 
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
            input.parse(as: CodeUnit.Unescaped.self, in: Void.self)
            let end:Location        = input.index 
            var string:String       = .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
            
            while let next:String   = input.parse(as: EscapeSequence?.self)
            {
                string             += next 
                let start:Location  = input.index 
                input.parse(as: CodeUnit.Unescaped.self, in: Void.self)
                let end:Location    = input.index 
                string             += .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
            }
            
            try                 input.parse(as: ASCII.Quote.self)
            return string 
        }
    }
    public 
    enum Whitespace:Grammar.TerminalClass 
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
    
    public 
    typealias Padded<Rule> = Grammar.Pad<Rule, Whitespace> 
        where Rule:ParsingRule, Rule.Location == Location, Rule.Terminal == UInt8
    
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
    public 
    enum Object:ParsingRule 
    {
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

extension JSON:CustomStringConvertible 
{
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
