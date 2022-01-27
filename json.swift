enum JSON
{
    struct InvalidUnicodeScalarError:Error
    {
        let value:UInt16  
    }
    
    enum Value:Grammar.Parsable
    {
        typealias Terminal = Character
        
        case null 
        case bool(Bool)
        case number(Number)
        case string(String)
        case array([Self])
        case object([String: Self])
        
        init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
        {
            if      let _:Void          = try? input.parse(terminals: "null")
            {
                self = .null 
            }
            else if let _:Void          = try? input.parse(terminals: "true")
            {
                self = .bool(true)
            }
            else if let _:Void          = try? input.parse(terminals: "false")
            {
                self = .bool(false)
            }
            else if let number:Number   = try? input.parse(as: Number.self)
            {
                self = .number(number)
            }
            else if let string:String   = try? input.parse(as: StringLiteral.self)
            {
                self = .string(string)
            }
            else if let elements:[Self] = try? input.parse(as: Array.self)
            {
                self = .array(elements)
            }
            else 
            {
                self = .object(           try  input.parse(as: Object.self))
            }
        }
    }
}
extension JSON 
{
    struct Number:Grammar.Parsable 
    {
        typealias Terminal = Character
        
        enum Sign:Grammar.TerminalClass 
        {
            typealias Terminal = Character
            
            case plus 
            case minus 
            
            init?(terminal character:Character)
            {
                switch character 
                {
                case "+":   self = .plus 
                case "-":   self = .minus
                default:    return nil
                }
            }
            
            var terminal:Character 
            {
                switch self 
                {
                case .plus:     return "+"
                case .minus:    return "-"
                }
            }
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
        
        init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
        {
            if let _:Void = try? input.parse(terminal: "-")
            {
                self.sign = .minus 
            }
            else 
            {
                self.sign = .plus 
            }
            
            let integer:Grammar.BigEndian   = try input.parse(as: Grammar.Reduce<Character.Digit, Grammar.BigEndian>.self)
            self.units                      = try integer.as(UInt64.self, radix: 10)
            
            if  let    (_, fraction):(Void,                                             Grammar.BigEndian) = 
                try? input.parse(as: (Character.Period, Grammar.Reduce<Character.Digit, Grammar.BigEndian>).self)
            {
                self.places     = fraction.count
                if  self.units != 0 
                {
                    // cannot do this if units == 0, since this may cause integer overflow
                    guard       let unit:UInt64     = Base10.Exp[exactly: self.places, as: UInt64.self], 
                        case   (let shifted, false) = self.units.multipliedReportingOverflow(by: unit)
                    else 
                    {
                        throw Grammar.IntegerOverflowError<UInt64>.init()
                    }
                    self.units  = shifted
                }
                
                guard case (let refined, false) = self.units.addingReportingOverflow(try fraction.as(UInt64.self, radix: 10))
                else 
                {
                    throw Grammar.IntegerOverflowError<UInt64>.init()
                }
                self.units      = refined
            }
            else 
            {
                self.places     = 0
            }
            
            if  let (_, sign, exponent):(Void,                Sign?,                                 Grammar.BigEndian) = 
                try?    input.parse(as: (Character.E.Anycase, Sign?, Grammar.Reduce<Character.Digit, Grammar.BigEndian>).self)
            {
                let exponent:Int = try exponent.as(Int.self, radix: 10)
                switch sign
                {
                case .minus?:
                    self.places        += exponent 
                case .plus?, nil:
                    if self.places      < exponent
                    {
                        if self.units  != 0 
                        {
                            guard       let factor:UInt64   = Base10.Exp[exactly: exponent - self.places, as: UInt64.self], 
                                case   (let shifted, false) = self.units.multipliedReportingOverflow(by: factor)
                            else 
                            {
                                throw Grammar.IntegerOverflowError<UInt64>.init()
                            }
                            self.units = shifted
                        }
                        self.places     = 0 
                    }
                    else 
                    {
                        self.places    -= exponent
                    }
                }
            }
        }
    }
    struct StringLiteral:Grammar.Parsable 
    {
        typealias Terminal = Character

        private 
        struct Element:Grammar.Parsable 
        {
            typealias Terminal = Character
            
            private 
            struct Escaped:Grammar.TerminalClass 
            {
                typealias Terminal = Character
                
                let production:Character 
                
                init?(terminal character:Character)
                {
                    switch character
                    {
                    case "\\", "/": self.production = character
                    case "b":       self.production = "\u{08}"
                    case "f":       self.production = "\u{0C}"
                    case "n":       self.production = "\u{0A}"
                    case "r":       self.production = "\u{0D}"
                    case "t":       self.production = "\u{09}"
                    default:        return nil 
                    }
                }
            }
            private 
            struct Unescaped:Grammar.TerminalClass
            {
                typealias Terminal = Character
                
                let production:Character 
                
                init?(terminal character:Character)
                {
                    for scalar:Unicode.Scalar in character.unicodeScalars
                    {
                        switch scalar 
                        {
                        case "\u{20}" ... "\u{21}", "\u{23}" ... "\u{5B}", "\u{5D}" ... "\u{10FFFF}":
                            break  
                        default:
                            return nil
                        }
                    }
                    self.production = character
                }
            } 
            
            let production:Character 
            
            init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
            {
                if let character:Character = try? input.parse(as: Unescaped.self) 
                {
                    self.production = character 
                }
                else 
                {
                    try input.parse(terminal: "\\")
                    if let character:Character = try? input.parse(as: Escaped.self)
                    {
                        self.production = character 
                    }
                    else 
                    {
                        try input.parse(terminal: "u") 
                        let hex:Grammar.BigEndian   = try input.parse(
                            as: Grammar.Reduce4<Character.HexDigit.Anycase, Grammar.BigEndian>.self)
                        // should never actually throw 
                        let value:UInt16            = try hex.as(UInt16.self, radix: 16)
                        guard let scalar:Unicode.Scalar = .init(value)
                        else 
                        {
                            throw JSON.InvalidUnicodeScalarError.init(value: value)
                        }
                        self.production = Character.init(scalar)
                    }
                }
            }
        }
        
        let production:String 
        
        init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
        {
            try                 input.parse(terminal: "\"")
            self.production =   input.parse(as: Element.self, in: String.self)
            try                 input.parse(terminal: "\"")
        }
    }
}
extension JSON 
{
    private 
    struct Whitespace:Grammar.TerminalClass 
    {
        typealias Terminal = Character
        init?(terminal character:Character)
        {
            switch character 
            {
            case " ", "\t", "\n", "\r":
                return 
            default:
                return nil
            }
        }
        var terminal:Character
        {
            " "
        }
        var production:Void 
        {
            ()
        }
        init(production _:Void)
        {
        }
    }
    
    enum Separator 
    {
        struct Name:Grammar.Parsable 
        {
            typealias Terminal = Character
            var production:Void 
            {
                ()
            }
            init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
            {
                    input.parse(as: Whitespace.self, in: Void.self)
                try input.parse(terminal: ":") 
                    input.parse(as: Whitespace.self, in: Void.self)
            }
        }
        struct Value:Grammar.Parsable 
        {
            typealias Terminal = Character
            var production:Void 
            {
                ()
            }
            init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
            {
                    input.parse(as: Whitespace.self, in: Void.self)
                try input.parse(terminal: ",") 
                    input.parse(as: Whitespace.self, in: Void.self)
            }
        }
    }
    struct Array:Grammar.Parsable 
    {
        typealias Terminal = Character
        
        let production:[Value]
        init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal 
        {
            try input.parse(as: ([Whitespace], Character.BracketLeft, [Whitespace]).self)
            
            if let head:Value = try? input.parse(as: Value.self)
            {
                var elements:[Value] = [head]
                while let (_, value):(Void, Value) = try? input.parse(as: (Separator.Value, Value).self)
                {
                    elements.append(value)
                }
                self.production = elements
            }
            else 
            {
                self.production = []
            }
            
            try input.parse(as: ([Whitespace], Character.BracketRight, [Whitespace]).self)
        }
    }
    struct Object:Grammar.Parsable 
    {
        typealias Terminal = Character
        struct Item:Grammar.Parsable 
        {
            typealias Terminal = Character
            
            let key:String 
            let value:Value 
            init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
            {
                self.key    =   try input.parse(as: StringLiteral.self)
                                try input.parse(as: Separator.Name.self)
                self.value  =   try input.parse(as: Value.self)
            }
        }
        
        let production:[String: Value]
        
        init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal 
        {
            try input.parse(as: ([Whitespace], Character.BraceLeft, [Whitespace]).self)
            
            if let head:Item = try? input.parse(as: Item.self)
            {
                var items:[String: Value]             = [head.key: head.value]
                while let (_, item):(Void, Item) = try? input.parse(as: (Separator.Value, Item).self)
                {
                    items[item.key] = item.value 
                }
                self.production = items 
            }
            else 
            {
                self.production = [:]
            }
            
            try input.parse(as: ([Whitespace], Character.BraceRight, [Whitespace]).self)
        }
    }
}
extension JSON.StringLiteral 
{
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
}
extension JSON.Value:CustomStringConvertible 
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
            guard let decimal:Decimal<Int64> = value.decimal 
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
    var decimal:Decimal<Int64>? 
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
    
    struct Decoder:Grammar.Parsable
    {
        typealias Terminal = Character
        
        let codingPath:[CodingKey]
        let userInfo:[CodingUserInfoKey: Any]
        
        let value:JSON.Value
        
        fileprivate 
        init(_ value:JSON.Value, path:[CodingKey])
        {
            self.value      = value 
            self.codingPath = path 
            self.userInfo   = [:]
        }
        
        init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal 
        {
            if let elements:[JSON.Value]        = try? input.parse(as: JSON.Array.self)
            {
                self.value = .array(elements)
            }
            else
            {
                let items:[String: JSON.Value]  = try  input.parse(as: JSON.Object.self)
                self.value = .object(items)
            }
            self.codingPath = [ ]
            self.userInfo   = [:]
        }
    }
}
extension JSON.Array 
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
extension JSON.Value
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
        guard   case .number(let value)     = self, 
                let decimal:Decimal<Int64>  = value.decimal 
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
        let dictionary:[String: JSON.Value]
        
        init(dictionary:[String: JSON.Value], path:[CodingKey])
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
        func value(_ key:Key) throws -> JSON.Value 
        {
            guard let child:JSON.Value = self.dictionary[key.stringValue]
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
        let array:[JSON.Value]
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
        
        init(array:[JSON.Value], path:[CodingKey])
        {
            self.codingPath     = path
            self.currentIndex   = array.startIndex 
            self.array          = array 
        }
        
        private mutating 
        func next() throws -> JSON.Value 
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
            self.codingPath + [JSON.Array.Index.init(intValue: self.currentIndex)]
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
