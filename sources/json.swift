@_exported import Grammar

#if swift(>=5.5)
extension JSON:Sendable {}
extension JSON.Number:Sendable {}
extension JSON.IntegerOverflowError:Sendable {}
extension JSON.InvalidUnicodeScalarError:Sendable {}
#endif 
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
    
    public 
    struct InvalidUnicodeScalarError:Error
    {
        public
        let value:UInt16  
        @inlinable public 
        init(value:UInt16)
        {
            self.value = value
        }
    }
    // this is distinct from `Grammar.IntegerOverflowError<T>`, and only thrown
    // by the conversions on `Number`. this is the error thrown by the `Decoder`
    // implementation.
    public
    struct IntegerOverflowError:Error, CustomStringConvertible 
    {
        public
        let number:Number
        
        #if swift(<5.7)
        public
        let type:Any.Type
        
        init(number:Number, overflows:Any.Type)
        {
            self.number = number 
            self.type   = overflows 
        }
        #else 
        @available(swift, deprecated: 5.7, message: "use the more strongly-typed `overflows` property")
        public
        var type:Any.Type { self.overflows }
        
        @available(swift, introduced: 5.7)
        public
        let overflows:any FixedWidthInteger.Type
        #endif
        
        public
        var description:String 
        {
            #if swift(<5.7)
            return "integer literal '\(number)' overflows decoded type '\(self.type)'"
            #else 
            "integer literal '\(number)' overflows decoded type '\(self.overflows)'"
            #endif
        }
    }
    
    // this layout should allow instances of `Number` to fit in 2 words
    @frozen public 
    struct Number:CustomStringConvertible
    {
        // this is backed by an `Int`, but the swift compiler can optimize it 
        // into a `UInt8`-sized field
        public 
        var sign:FloatingPointSign 
        // cannot have an inlinable property wrapper
        public 
        var _places:UInt32
        @inlinable public 
        var places:UInt64 
        {
            .init(self._places)
        }
        public 
        var units:UInt64
        
        @inlinable public
        init(sign:FloatingPointSign, units:UInt64, places:UInt32)
        {
            self.sign       = sign 
            self.units      = units 
            self._places    = places
        }
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
        public
        func callAsFunction<T>(as _:T?.Type) -> T? where T:FixedWidthInteger & UnsignedInteger 
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
        public
        func callAsFunction<T>(as _:T?.Type) -> T? where T:FixedWidthInteger & SignedInteger 
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
        public
        func callAsFunction<T>(as _:(units:T, places:T)?.Type) -> (units:T, places:T)? 
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
        public
        func callAsFunction<T>(as _:T.Type) -> T where T:BinaryFloatingPoint 
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
    public 
    enum Base10
    {
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
        public 
        enum Inverse 
        {
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
    
    // includes quotes!
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
    
    case null 
    case bool(Bool)
    case number(Number)
    case string(String)
    case array([Self])
    case object([String: Self])
}

extension JSON 
{
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
            if let items:[String: JSON] = input.parse(as: Object?.self)
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
            if let number:JSON.Number           = input.parse(as: NumberLiteral?.self)
            {
                return .number(number)
            }
            else if let string:String           = input.parse(as: StringLiteral?.self)
            {
                return .string(string)
            }
            else if let elements:[JSON]         = input.parse(as: Array?.self)
            {
                return .array(elements)
            }
            else if let items:[String: JSON]    = input.parse(as: Object?.self)
            {
                return .object(items)
            }
            else if let _:Void                  = input.parse(as: Keyword.True?.self)
            {
                return .bool(true)
            }
            else if let _:Void                  = input.parse(as: Keyword.False?.self)
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
                while let (_, value):(Void, JSON) = try? input.parse(as: (Padded<ASCII.Comma>, Value).self)
                {
                    elements.append(value)
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
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> [String: JSON]
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            try input.parse(as: Padded<ASCII.BraceLeft>.self)
            var items:[String: JSON]
            if let head:(key:String, value:JSON) = try? input.parse(as: Item.self)
            {
                items = [head.key: head.value]
                while let (_, item):(Void, (key:String, value:JSON)) = try? input.parse(as: (Padded<ASCII.Comma>, Item).self)
                {
                    items[item.key] = item.value 
                }
            }
            else 
            {
                items = [:]
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
