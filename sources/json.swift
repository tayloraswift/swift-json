enum JSON
{
    struct InvalidUnicodeScalarError:Error
    {
        let value:UInt16  
    }
    
    struct Number 
    {
        enum Sign
        {
            case plus 
            case minus 
        }
        
        var sign:Sign, 
            units:UInt64, 
            places:Int
        
        init(sign:Sign, units:UInt64, places:Int)
        {
            self.sign   = sign 
            self.units  = units 
            self.places = places 
        }
    }
    
    // includes quotes!
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
            case "/":       escaped += "\\/"
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
    
    fileprivate 
    struct _Decimal 
    {
        let units:Int64, 
            places:Int64
        
        // do not edit me! i was copied-and-pasted from `decimal.swift`!
        var normalized:Self 
        {
            var places:Int64   = self.places, 
                units:Int64    = self.units 
            // steve canon, feel free to submit a PR
            while places > 0 
            {
                let (quotient, remainder):(Int64, Int64) = units.quotientAndRemainder(dividingBy: 10)
                guard remainder == 0 
                else 
                {
                    break 
                }
                
                units   = quotient
                places -= 1
            }
            return Self.init(units: units, places: places)
        }
        
        // do not edit me! i was copied-and-pasted from `decimal.swift`!
        func description(separator:String = ".", 
            prefix:(positive:String, negative:String) = (positive: "", negative: "-")) 
            -> String 
        {
            guard self.places > 0 
            else 
            {
                return "\(self.units)"
            }
            
            let places:Int      = .init(self.places)
            let unpadded:String = .init(Swift.abs(self.units))
            let string:String   = "\(String.init(repeating: "0", count: Swift.max(0, 1 + places - unpadded.count)))\(unpadded)"
            return "\(self.units < 0 ? prefix.negative : prefix.positive)\(string.dropLast(places))\(separator)\(string.suffix(places))"
        }
    }
    fileprivate 
    enum Base10
    {
        static
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
        enum Inverse 
        {
            static 
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
    
    case null 
    case bool(Bool)
    case number(Number)
    case string(String)
    case array([Self])
    case object([String: Self])
    
    enum Rule<Location> 
    {
        typealias Codepoint = Grammar.Encoding<Location, Unicode.Scalar>
        typealias Digit<T>  = Grammar.Digit<Location, Unicode.Scalar, T> where T:BinaryInteger
    }
}
extension JSON.Rule 
{
    private
    enum Keyword
    {
        enum Null:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["n", "u", "l", "l"] }
        }
        enum True:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["t", "r", "u", "e"] }
        }
        enum False:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["f", "a", "l", "s", "e"] }
        }
    }
    
    enum Root:ParsingRule 
    {
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Source>(_ input:inout ParsingInput<Source>) throws -> JSON.Decoder
            where Source:Collection, Source.Index == Location, Source.Element == Terminal
        {
            if let items:[String: JSON] = input.parse(as: Object?.self)
            {
                return .init(.object(items), path: [])
            }
            else 
            {
                return .init(.array(try input.parse(as: Array.self)), path: [])
            }
        }
    }
    private
    enum Value:ParsingRule
    {
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Source>(_ input:inout ParsingInput<Source>) throws -> JSON
            where Source:Collection, Source.Index == Location, Source.Element == Terminal
        {
            if      let _:Void          = input.parse(as: Keyword.Null?.self)
            {
                return .null 
            }
            else if let _:Void          = input.parse(as: Keyword.True?.self)
            {
                return .bool(true)
            }
            else if let _:Void          = input.parse(as: Keyword.False?.self)
            {
                return .bool(false)
            }
            else if let number:JSON.Number = input.parse(as: NumberLiteral?.self)
            {
                return .number(number)
            }
            else if let string:String   = input.parse(as: StringLiteral?.self)
            {
                return .string(string)
            }
            else if let elements:[JSON] = input.parse(as: Array?.self)
            {
                return .array(elements)
            }
            else 
            {
                return .object(try input.parse(as: Object.self))
            }
        }
    }
    
    private
    enum NumberLiteral:ParsingRule
    {
        private 
        enum PlusOrMinus:Grammar.TerminalClass 
        {
            typealias Terminal      = Unicode.Scalar
            typealias Construction  = JSON.Number.Sign
            
            static 
            func parse(terminal:Unicode.Scalar) -> JSON.Number.Sign? 
            {
                switch terminal 
                {
                case "+":   return .plus 
                case "-":   return .minus
                default:    return nil
                }
            }
        }
        
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Source>(_ input:inout ParsingInput<Source>) throws -> JSON.Number
            where Source:Collection, Source.Index == Location, Source.Element == Terminal
        {
            // https://datatracker.ietf.org/doc/html/rfc8259#section-6
            // JSON does not allow prefix '+'
            let sign:JSON.Number.Sign 
            switch input.parse(as: Codepoint.Minus?.self)
            {
            case  _?:   sign = .minus 
            case nil:   sign = .plus
            }
            
            var units:UInt64    = 
                try  input.parse(as: Grammar.UnsignedIntegerLiteral<Digit<UInt64>.Decimal>.self)
            var places:Int      = 0
            if  var (_, remainder):(Void, UInt64) = 
                try? input.parse(as: (Codepoint.Period, Digit<UInt64>.Decimal).self)
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
            if  let _:Void                  =     input.parse(as: Codepoint.E.Anycase?.self) 
            {
                let sign:JSON.Number.Sign?  =     input.parse(as: PlusOrMinus?.self)
                let exponent:Int            = try input.parse(as: Grammar.UnsignedIntegerLiteral<Digit<Int>.Decimal>.self)
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
                    let shift:Int   = exponent - places 
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
    enum StringLiteral:ParsingRule 
    {
        private 
        enum Element:ParsingRule 
        {
            private 
            enum Escaped:Grammar.TerminalClass 
            {
                typealias Terminal      = Unicode.Scalar
                typealias Construction  = Unicode.Scalar 
                static 
                func parse(terminal:Unicode.Scalar) -> Unicode.Scalar? 
                {
                    switch terminal
                    {
                    case "\\", "/": return terminal
                    case "b":       return "\u{08}"
                    case "f":       return "\u{0C}"
                    case "n":       return "\u{0A}"
                    case "r":       return "\u{0D}"
                    case "t":       return "\u{09}"
                    default:        return nil 
                    }
                }
            }
            private 
            enum Unescaped:Grammar.TerminalClass
            {
                typealias Terminal      = Unicode.Scalar
                typealias Construction  = Unicode.Scalar 
                static 
                func parse(terminal:Unicode.Scalar) -> Unicode.Scalar? 
                {
                    switch terminal 
                    {
                    case "\u{20}" ... "\u{21}", "\u{23}" ... "\u{5B}", "\u{5D}" ... "\u{10FFFF}":
                        return terminal 
                    default:
                        return nil
                    }
                }
            } 
            
            typealias Terminal = Unicode.Scalar
            static 
            func parse<Source>(_ input:inout ParsingInput<Source>) throws -> Character
                where Source:Collection, Source.Index == Location, Source.Element == Terminal
            {
                if let scalar:Unicode.Scalar = input.parse(as: Unescaped?.self) 
                {
                    return Character.init(scalar)
                }
                try input.parse(as: Codepoint.Backslash.self)
                if let scalar:Unicode.Scalar = input.parse(as: Escaped?.self)
                {
                    return Character.init(scalar)
                }
                try input.parse(as: Codepoint.U.Lowercase.self) 
                let value:UInt16 = 
                    (try input.parse(as: Digit<UInt16>.Hex.Anycase.self) << 12) |
                    (try input.parse(as: Digit<UInt16>.Hex.Anycase.self) <<  8) |
                    (try input.parse(as: Digit<UInt16>.Hex.Anycase.self) <<  4) |
                    (try input.parse(as: Digit<UInt16>.Hex.Anycase.self)) 
                if let scalar:Unicode.Scalar = .init(value)
                {
                    return Character.init(scalar)
                }
                else 
                {
                    throw JSON.InvalidUnicodeScalarError.init(value: value)
                }
            }
        }
        
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Source>(_ input:inout ParsingInput<Source>) throws -> String
            where Source:Collection, Source.Index == Location, Source.Element == Terminal
        {
            try                 input.parse(as: Codepoint.Quote.self)
            let string:String = input.parse(as: Element.self, in: String.self)
            try                 input.parse(as: Codepoint.Quote.self)
            return string 
        }
    }
    
    private 
    enum Whitespace:Grammar.TerminalClass 
    {
        typealias Terminal      = Unicode.Scalar
        typealias Construction  = Void 
        static 
        func parse(terminal:Unicode.Scalar) -> Void? 
        {
            switch terminal 
            {
            case " ", "\t", "\n", "\r": return ()
            default:                    return nil
            }
        }
    }
    
    private 
    typealias Padded<Rule> = Grammar.Pad<Rule, Whitespace> 
        where Rule:ParsingRule, Rule.Location == Location, Rule.Terminal == Unicode.Scalar
    
    private 
    enum Array:ParsingRule 
    {
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Source>(_ input:inout ParsingInput<Source>) throws -> [JSON]
            where Source:Collection, Source.Index == Location, Source.Element == Terminal
        {
            try input.parse(as: Padded<Codepoint.BracketLeft>.self)
            var elements:[JSON]
            if let head:JSON = try? input.parse(as: Value.self)
            {
                elements = [head]
                while let (_, value):(Void, JSON) = try? input.parse(as: (Padded<Codepoint.Comma>, Value).self)
                {
                    elements.append(value)
                }
            }
            else 
            {
                elements = []
            }
            try input.parse(as: Padded<Codepoint.BracketRight>.self)
            return elements
        }
    }
    enum Object:ParsingRule 
    {
        enum Item:ParsingRule 
        {
            typealias Terminal = Unicode.Scalar
            static 
            func parse<Source>(_ input:inout ParsingInput<Source>) throws -> (key:String, value:JSON)
                where Source:Collection, Source.Index == Location, Source.Element == Terminal
            {
                let key:String  = try input.parse(as: StringLiteral.self)
                try input.parse(as: Padded<Codepoint.Colon>.self)
                let value:JSON  = try input.parse(as: Value.self)
                return (key, value)
            }
        }
        
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Source>(_ input:inout ParsingInput<Source>) throws -> [String: JSON]
            where Source:Collection, Source.Index == Location, Source.Element == Terminal
        {
            try input.parse(as: Padded<Codepoint.BraceLeft>.self)
            var items:[String: JSON]
            if let head:(key:String, value:JSON) = try? input.parse(as: Item.self)
            {
                items = [head.key: head.value]
                while let (_, item):(Void, (key:String, value:JSON)) = try? input.parse(as: (Padded<Codepoint.Comma>, Item).self)
                {
                    items[item.key] = item.value 
                }
            }
            else 
            {
                items = [:]
            }
            try input.parse(as: Padded<Codepoint.BraceRight>.self)
            return items
        }
    }
}
fileprivate 
extension BinaryFloatingPoint 
{
    // do not edit me! i was copied-and-pasted from `decimal.swift`!
    init(_ decimal:JSON._Decimal) 
    {
        let normalized:JSON._Decimal = decimal.normalized
        self = Self.init(normalized.units) * JSON.Base10.Inverse[Int.init(normalized.places), as: Self.self]
    }
}


extension JSON.Rule.StringLiteral 
{

}
extension JSON:CustomStringConvertible 
{
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
            guard let decimal:JSON._Decimal = value._decimal 
            else 
            {
                fatalError("integer overflow")
            }
            return decimal.description(separator: ".")
        case .string(let string):
            return "\"\(string)\""
        case .array(let elements):
            return "[\(elements.map(\.description).joined(separator: ", "))]"
        case .object(let items):
            return "{\(items.map{ "\"\($0.key)\": \($0.value)" }.joined(separator: ", "))}"
        }
    }
}

extension JSON.Number 
{
    fileprivate 
    var _decimal:JSON._Decimal? 
    {
        let units:Int64 
        switch self.sign 
        {
        case .plus: 
            guard   let integer:Int64   = .init(exactly:         self.units)
            else 
            {
                return nil 
            }
            units = integer 
        case .minus: 
            let         integer:Int64   = .init(bitPattern: 0 &- self.units)
            guard       integer        <= 0
            else 
            {
                return nil 
            }
            units = integer 
        }
        return .init(units: units, places: Int64.init(self.places))
    }
}
extension JSON 
{
    enum DecodingError:Error 
    {
        case invalidIndex(Int,  path:[CodingKey])
        case invalidKey(String, path:[CodingKey])
        case expectedUnkeyedContainer
        case expectedKeyedContainer
        
        case cannotConvert
    }
    
    struct Decoder
    {
        let codingPath:[CodingKey]
        let userInfo:[CodingUserInfoKey: Any]
        
        let value:JSON
        
        fileprivate 
        init(_ value:JSON, path:[CodingKey])
        {
            self.value      = value 
            self.codingPath = path 
            self.userInfo   = [:]
        }
    }
}
extension JSON 
{
    struct Index:CodingKey 
    {
        private 
        let value:Int
        var intValue:Int? 
        {
            self.value 
        }
        var stringValue:String
        {
            "\(self.value)"
        }
        
        init(intValue:Int)
        {
            self.value = intValue
        }
        init?(stringValue:String)
        {
            guard let value:Int = .init(stringValue)
            else 
            {
                return nil 
            }
            self.value = value
        }
    }
}
extension JSON
{
    func decodeNil() -> Bool
    {
        guard case .null = self 
        else 
        {
            return false 
        }
        return true
    }
    func decode(_:Bool.Type) throws -> Bool
    {
        guard case .bool(let value) = self 
        else 
        {
            throw JSON.DecodingError.cannotConvert
        }
        return value
    }
    func decode<T>(_:T.Type) throws -> T 
        where T:FixedWidthInteger & SignedInteger
    {
        // do not use init(exactly:) with decimal value directly, as this 
        // will also accept values like 1.0, which we want to reject
        guard case .number(let value) = self, value.places == 0
        else 
        {
            throw JSON.DecodingError.cannotConvert
        }
            
        switch value.sign 
        {
        case .plus: 
            if  let integer:T       = .init(exactly: value.units)
            {
                return integer 
            }
        case .minus: 
            let     negated:Int64   = .init(bitPattern: 0 &- value.units)
            if      negated        <= 0, 
                let integer:T       = .init(exactly: negated)
            {
                return integer 
            }
        }
        
        throw JSON.DecodingError.cannotConvert
    }
    func decode<T>(_:T.Type) throws -> T 
        where T:FixedWidthInteger & UnsignedInteger
    {
        guard   case .number(let value) = self, 
                case .plus              = value.sign, value.places == 0, 
                let integer:T           = .init(exactly: value.units)
        else 
        {
            throw JSON.DecodingError.cannotConvert
        }
        return integer 
    }
    func decode<T>(_:T.Type) throws -> T 
        where T:BinaryFloatingPoint
    {
        guard   case .number(let value) = self, 
                let decimal:JSON._Decimal    = value._decimal 
        else 
        {
            throw JSON.DecodingError.cannotConvert
        }
        return .init(decimal)
    }
    func decode(_:String.Type) throws -> String
    {
        switch self 
        {
        case .string(let value):    return value
        default:                    throw  JSON.DecodingError.cannotConvert
        }
    }
    func decode<T>(_:T.Type, path:[CodingKey]) throws -> T 
        where T:Decodable
    {
        try .init(from: JSON.Decoder.init(self, path: path))
    }
    
    func decodeContainer<Key>(keyedBy _:Key.Type, path:[CodingKey]) throws 
        -> JSON.Decoder.KeyedContainer<Key>
        where Key:CodingKey 
    {
        switch self 
        {
        case .object(let dictionary):
            return .init(dictionary: dictionary, path: path)
        case .number(let value):
            return .init(dictionary: 
            [
                "units":  .number(.init(sign: value.sign, units:             value.units,   places: 0)),
                "places": .number(.init(sign:      .plus, units: UInt64.init(value.places), places: 0)),
            ], path: path)
        default:
            throw JSON.DecodingError.expectedKeyedContainer
        }
    }
    func decodeContainer(keyedBy _:Void.Type, path:[CodingKey]) throws 
        -> JSON.Decoder.UnkeyedContainer
    {
        guard case .array(let array) = self 
        else 
        {
            throw JSON.DecodingError.expectedUnkeyedContainer
        }
        return .init(array: array, path: path)
    }
}
extension JSON.Decoder:Decoder & SingleValueDecodingContainer
{
    struct KeyedContainer<Key>:KeyedDecodingContainerProtocol
        where Key:CodingKey
    {
        let codingPath:[CodingKey]
        let allKeys:[Key]
        let dictionary:[String: JSON]
        
        init(dictionary:[String: JSON], path:[CodingKey])
        {
            self.codingPath = path
            self.allKeys    = dictionary.keys.compactMap(Key.init(stringValue:))
            self.dictionary = dictionary 
        }
        
        func contains(_ key:Key) -> Bool 
        {
            self.dictionary.index(forKey: key.stringValue) != nil
        }
        
        private 
        func value(_ key:Key) throws -> JSON 
        {
            guard let child:JSON = self.dictionary[key.stringValue]
            else 
            {
                throw JSON.DecodingError.invalidKey(key.stringValue, path: self.codingPath)
            }
            return child
        }
        
        func decodeNil(forKey key:Key) -> Bool
        {
            self.dictionary[key.stringValue]?.decodeNil() ?? true
        }
        func decode(_:Bool.Type, forKey key:Key) throws -> Bool
        {
            try self.value(key).decode(Bool.self)
        }
        func decode(_:Int.Type, forKey key:Key) throws -> Int
        {
            try self.value(key).decode(Int.self)
        }
        func decode(_:Int64.Type, forKey key:Key) throws -> Int64
        {
            try self.value(key).decode(Int64.self)
        }
        func decode(_:Int32.Type, forKey key:Key) throws -> Int32
        {
            try self.value(key).decode(Int32.self)
        }
        func decode(_:Int16.Type, forKey key:Key) throws -> Int16
        {
            try self.value(key).decode(Int16.self)
        }
        func decode(_:Int8.Type, forKey key:Key) throws -> Int8
        {
            try self.value(key).decode(Int8.self)
        }
        func decode(_:UInt.Type, forKey key:Key) throws -> UInt
        {
            try self.value(key).decode(UInt.self)
        }
        func decode(_:UInt64.Type, forKey key:Key) throws -> UInt64
        {
            try self.value(key).decode(UInt64.self)
        }
        func decode(_:UInt32.Type, forKey key:Key) throws -> UInt32
        {
            try self.value(key).decode(UInt32.self)
        }
        func decode(_:UInt16.Type, forKey key:Key) throws -> UInt16
        {
            try self.value(key).decode(UInt16.self)
        }
        func decode(_:UInt8.Type, forKey key:Key) throws -> UInt8
        {
            try self.value(key).decode(UInt8.self)
        }
        func decode(_:Float.Type, forKey key:Key) throws -> Float
        {
            try self.value(key).decode(Float.self)
        }
        func decode(_:Double.Type, forKey key:Key) throws -> Double
        {
            try self.value(key).decode(Double.self)
        }
        func decode(_:String.Type, forKey key:Key) throws -> String
        {
            try self.value(key).decode(String.self)
        }
        func decode<T>(_:T.Type, forKey key:Key) throws -> T 
            where T:Decodable
        {
            try self.value(key).decode(T.self, path: self.codingPath + [key])
        }
        
        func nestedContainer<NestedKey>(keyedBy _:NestedKey.Type, forKey key:Key) throws 
            -> KeyedDecodingContainer<NestedKey>
        {
            .init(try self.value(key).decodeContainer(keyedBy: NestedKey.self, 
                path: self.codingPath + [key]))
        }
        func nestedUnkeyedContainer(forKey key:Key) throws 
            -> UnkeyedDecodingContainer
        {
            try self.value(key).decodeContainer(keyedBy: Void.self, 
                path: self.codingPath + [key])
        }
        
        func superDecoder() -> Decoder
        {
            fatalError("unimplemented")
        }
        func superDecoder(forKey key:Key) -> Decoder
        {
            fatalError("unimplemented")
        }
    }
    struct UnkeyedContainer:UnkeyedDecodingContainer
    {
        let codingPath:[CodingKey]
        
        private 
        let array:[JSON]
        private(set)
        var currentIndex:Int 
        
        var count:Int?
        {
            self.array.count
        }
        var isAtEnd:Bool 
        {
            self.currentIndex >= self.array.endIndex
        }
        
        init(array:[JSON], path:[CodingKey])
        {
            self.codingPath     = path
            self.currentIndex   = array.startIndex 
            self.array          = array 
        }
        
        private mutating 
        func next() throws -> JSON 
        {
            if self.isAtEnd 
            {
                throw JSON.DecodingError.invalidIndex(self.currentIndex, path: self.codingPath)
            }
            defer 
            {
                self.currentIndex += 1
            }
            return self.array[self.currentIndex]
        }
        
        mutating 
        func decodeNil() throws -> Bool
        {
            if self.isAtEnd 
            {
                throw JSON.DecodingError.invalidIndex(self.currentIndex, path: self.codingPath)
            }
            if self.array[self.currentIndex].decodeNil()
            {
                self.currentIndex += 1
                return true 
            }
            else 
            {
                return false 
            }
        }
        mutating 
        func decode(_:Bool.Type) throws -> Bool
        {
            try self.next().decode(Bool.self)
        }
        mutating 
        func decode(_:Int.Type) throws -> Int
        {
            try self.next().decode(Int.self)
        }
        mutating 
        func decode(_:Int64.Type) throws -> Int64
        {
            try self.next().decode(Int64.self)
        }
        mutating 
        func decode(_:Int32.Type) throws -> Int32
        {
            try self.next().decode(Int32.self)
        }
        mutating 
        func decode(_:Int16.Type) throws -> Int16
        {
            try self.next().decode(Int16.self)
        }
        mutating 
        func decode(_:Int8.Type) throws -> Int8
        {
            try self.next().decode(Int8.self)
        }
        mutating 
        func decode(_:UInt.Type) throws -> UInt
        {
            try self.next().decode(UInt.self)
        }
        mutating 
        func decode(_:UInt64.Type) throws -> UInt64
        {
            try self.next().decode(UInt64.self)
        }
        mutating 
        func decode(_:UInt32.Type) throws -> UInt32
        {
            try self.next().decode(UInt32.self)
        }
        mutating 
        func decode(_:UInt16.Type) throws -> UInt16
        {
            try self.next().decode(UInt16.self)
        }
        mutating 
        func decode(_:UInt8.Type) throws -> UInt8
        {
            try self.next().decode(UInt8.self)
        }
        mutating 
        func decode(_:Float.Type) throws -> Float
        {
            try self.next().decode(Float.self)
        }
        mutating 
        func decode(_:Double.Type) throws -> Double
        {
            try self.next().decode(Double.self)
        }
        mutating 
        func decode(_:String.Type) throws -> String
        {
            try self.next().decode(String.self)
        }
        
        private 
        var nextPath:[CodingKey]
        {
            self.codingPath + [JSON.Index.init(intValue: self.currentIndex)]
        }
        
        mutating 
        func decode<T>(_:T.Type) throws -> T 
            where T:Decodable
        {
            let path:[CodingKey] = self.nextPath
            return try self.next().decode(T.self, path: path)
        }
        mutating 
        func nestedContainer<NestedKey>(keyedBy:NestedKey.Type) throws 
            -> KeyedDecodingContainer<NestedKey>
        {
            let path:[CodingKey] = self.nextPath
            return .init(try self.next().decodeContainer(keyedBy: NestedKey.self, 
                path: path))
        }
        mutating 
        func nestedUnkeyedContainer() throws 
            -> UnkeyedDecodingContainer
        {
            let path:[CodingKey] = self.nextPath
            return try self.next().decodeContainer(keyedBy: Void.self, 
                path: path)
        }
        
        func superDecoder() -> Decoder
        {
            fatalError("unimplemented")
        }
    }
    
    func decodeNil() -> Bool
    {
        self.value.decodeNil()
    }
    func decode(_:Bool.Type) throws -> Bool
    {
        try self.value.decode(Bool.self)
    }
    func decode(_:Int.Type) throws -> Int
    {
        try self.value.decode(Int.self)
    }
    func decode(_:Int64.Type) throws -> Int64
    {
        try self.value.decode(Int64.self)
    }
    func decode(_:Int32.Type) throws -> Int32
    {
        try self.value.decode(Int32.self)
    }
    func decode(_:Int16.Type) throws -> Int16
    {
        try self.value.decode(Int16.self)
    }
    func decode(_:Int8.Type) throws -> Int8
    {
        try self.value.decode(Int8.self)
    }
    func decode(_:UInt.Type) throws -> UInt
    {
        try self.value.decode(UInt.self)
    }
    func decode(_:UInt64.Type) throws -> UInt64
    {
        try self.value.decode(UInt64.self)
    }
    func decode(_:UInt32.Type) throws -> UInt32
    {
        try self.value.decode(UInt32.self)
    }
    func decode(_:UInt16.Type) throws -> UInt16
    {
        try self.value.decode(UInt16.self)
    }
    func decode(_:UInt8.Type) throws -> UInt8
    {
        try self.value.decode(UInt8.self)
    }
    func decode(_:Float.Type) throws -> Float
    {
        try self.value.decode(Float.self)
    }
    func decode(_:Double.Type) throws -> Double
    {
        try self.value.decode(Double.self)
    }
    func decode(_:String.Type) throws -> String
    {
        try self.value.decode(String.self)
    }
    func decode<T>(_:T.Type) throws -> T 
        where T:Decodable
    {
        try self.value.decode(T.self, path: self.codingPath)
    }
    
    func container<Key>(keyedBy _:Key.Type) throws -> KeyedDecodingContainer<Key> 
        where Key:CodingKey 
    {
        .init(try self.value.decodeContainer(keyedBy: Key.self, path: self.codingPath))
    }
    func unkeyedContainer() throws -> UnkeyedDecodingContainer
    {
        try self.value.decodeContainer(keyedBy: Void.self, path: self.codingPath)
    }
    func singleValueContainer() -> SingleValueDecodingContainer
    {
        self
    }
} 
