// primitive decoding hooks 
extension JSON
{
    struct Index:CodingKey 
    {
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
            guard let value:Int = Int.init(stringValue)
            else 
            {
                return nil 
            }
            self.value = value
        }
    }
    enum Key:String, CodingKey 
    {
        case `super` = "super"
    }
    
    func callAsFunction(is _:Void.Type) -> Bool
    {
        switch self 
        {
        case .null: return true 
        default:    return false
        }
    }
    func callAsFunction(as _:Bool.Type) -> Bool?
    {
        switch self 
        {
        case .bool(let value):  return value
        default:                return nil 
        }
    }
    func callAsFunction<T>(as _:T.Type) throws -> T? 
        where T:FixedWidthInteger & SignedInteger
    {
        // do not use init(exactly:) with decimal value directly, as this 
        // will also accept values like 1.0, which we want to reject
        guard case .number(let number) = self 
        else 
        {
            return nil
        }
        guard let integer:T = number(as: T?.self)
        else 
        {
            throw IntegerOverflowError.init(number: number, overflows: T.self)
        }
        return integer 
    }
    func callAsFunction<T>(as _:T.Type) throws -> T?
        where T:FixedWidthInteger & UnsignedInteger
    {
        guard case .number(let number) = self 
        else 
        {
            return nil
        }
        guard let integer:T = number(as: T?.self)
        else 
        {
            throw IntegerOverflowError.init(number: number, overflows: T.self)
        }
        return integer 
    }
    func callAsFunction<T>(as _:T.Type) -> T?
        where T:BinaryFloatingPoint
    {
        switch self 
        {
        case .number(let number):   return number(as: T.self)
        default:                    return nil 
        }
    }
    func callAsFunction(as _:String.Type) -> String?
    {
        switch self 
        {
        case .string(let string):   return string
        default:                    return nil
        }
    }
    func callAsFunction(as _:[Self].Type) -> [Self]?
    {
        switch self 
        {
        case .array(let elements):  return elements 
        default:                    return nil
        }
    }
    @available(*, deprecated, message: "handle duplicate keys explicitly with `callAsFunction(as:uniquingKeysWith:)`")
    func callAsFunction(as _:[String: Self].Type) -> [String: Self]? 
    {
        self(as: [String: Self].self) { $1 }
    }
    func callAsFunction(as _:[(key:String, value:Self)].Type) -> [(key:String, value:Self)]? 
    {
        switch self 
        {
        case .object(let items):
            return items
        case .number(let number):
            let units:Number    = .init(sign: number.sign, units: number.units,  places: 0),
                places:Number   = .init(sign:       .plus, units: number.places, places: 0)
            return [("units", .number(units)), ("places", .number(places))]
        default:
            return nil 
        }
    }
    func callAsFunction(as _:[String: Self].Type, 
        uniquingKeysWith combine:(Self, Self) throws -> Self) rethrows -> [String: Self]? 
    {
        try self(as: [(key:String, value:Self)].self).map
        {
            try [String: Self].init($0, uniquingKeysWith: combine)
        }
    }
}
extension JSON:Decoder 
{
    @inlinable public 
    var codingPath:[CodingKey] 
    {
        []
    }
    @inlinable public 
    var userInfo:[CodingUserInfoKey: Any] 
    {
        [:]
    }

    @inlinable public 
    func singleValueContainer() -> SingleValueDecodingContainer
    {
        Decoder.init(self, path: []) as SingleValueDecodingContainer
    }
    @inlinable public 
    func unkeyedContainer() throws -> UnkeyedDecodingContainer
    {
        try Decoder.init(self, path: []).unkeyedContainer()
    }
    @inlinable public 
    func container<Key>(keyedBy _:Key.Type) throws -> KeyedDecodingContainer<Key> 
        where Key:CodingKey 
    {
        try Decoder.init(self, path: []).container(keyedBy: Key.self)
    }
}
extension JSON 
{
    // this is specifically used for decoding nested values while keeping track 
    // of the coding path taken and user info provided from earlier decoding 
    // operations. 
    public 
    struct Decoder
    {
        let value:JSON
        public 
        let codingPath:[CodingKey]
        public 
        let userInfo:[CodingUserInfoKey: Any]
        
        public 
        init(_ value:JSON, path:[CodingKey], userInfo:[CodingUserInfoKey: Any] = [:])
        {
            self.value      = value 
            self.codingPath = path 
            self.userInfo   = userInfo
        }
    }
}
extension JSON.Decoder:SingleValueDecodingContainer
{
    static 
    func error<T>(annotating error:Error, initializing _:T.Type, path:[CodingKey]) -> DecodingError 
    {
        let description:String =
        """
        initializer for type '\(String.init(reflecting: T.self))' \
        threw an error while validating json value at coding path \(path)
        """
        let context:DecodingError.Context = .init(codingPath: path, 
            debugDescription: description, underlyingError: error)
        return .dataCorrupted(context)
    }
    static 
    func error<T>(typecasting value:JSON, to _:T.Type, path:[CodingKey]) -> DecodingError 
    {
        let description:String =
        """
        could not decode instance of type '\(String.init(reflecting: T.self))' \
        from json value '\(value)' at coding path \(path)
        """
        let context:DecodingError.Context = .init(codingPath: path, debugDescription: description)
        return .typeMismatch(T.self, context)
    }
    func diagnose<T>(_ decode:(T.Type) throws -> T?) throws -> T
    {
        do 
        {
            if let decoded:T = try decode(T.self)
            {
                return decoded 
            }
        }
        catch let error
        {
            throw Self.error(annotating: error, initializing: T.self, path: self.codingPath)
        }
        throw Self.error(typecasting: self.value, to: T.self, path: self.codingPath)
    }
    public
    func decodeNil() -> Bool
    {
        self.value(is: Void.self)
    }
    public
    func decode(_:Bool.Type) throws -> Bool
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:Int.Type) throws -> Int
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:Int64.Type) throws -> Int64
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:Int32.Type) throws -> Int32
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:Int16.Type) throws -> Int16
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:Int8.Type) throws -> Int8
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:UInt.Type) throws -> UInt
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:UInt64.Type) throws -> UInt64
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:UInt32.Type) throws -> UInt32
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:UInt16.Type) throws -> UInt16
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:UInt8.Type) throws -> UInt8
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:Float.Type) throws -> Float
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:Double.Type) throws -> Double
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public
    func decode(_:String.Type) throws -> String
    {
        try self.diagnose(self.value.callAsFunction(as:))
    }
    public 
    func decode<T>(_:T.Type) throws -> T where T:Decodable
    {
        try .init(from: self)
    }
}
extension JSON.Decoder:Decoder
{
    public 
    func singleValueContainer() -> SingleValueDecodingContainer
    {
        self
    }
    public 
    func unkeyedContainer() throws -> UnkeyedDecodingContainer
    {
        let elements:[JSON]                 = try self.diagnose(self.value.callAsFunction(as:))
        let decoder:JSON.Array              = .init(elements, path: self.codingPath)
        return       decoder as UnkeyedDecodingContainer        
    }
    public 
    func container<Key>(keyedBy _:Key.Type) throws -> KeyedDecodingContainer<Key> 
        where Key:CodingKey 
    {
        let decoder:JSON.Dictionary<Key> = .init(
            try     self.diagnose(self.value.callAsFunction(as:)), 
            path:   self.codingPath)
        {
            (_, overwrite) in overwrite 
        }
        return .init(decoder)
    }
}

extension JSON 
{    
    struct Dictionary<Key> where Key:CodingKey
    {
        let codingPath:[CodingKey]
        let allKeys:[Key]
        let items:[String: JSON]
        
        init(_ items:[(key:String, value:JSON)], path:[CodingKey], 
            uniquingKeysWith combine:(JSON, JSON) throws -> JSON) rethrows
        {
            self.init(try .init(items, uniquingKeysWith: combine), path: path)
        }
        init(_ items:[String: JSON], path:[CodingKey]) 
        {
            self.codingPath = path
            self.items      = items
            self.allKeys    = items.keys.compactMap(Key.init(stringValue:))
        }
    }
}
extension JSON.Dictionary:KeyedDecodingContainerProtocol 
{
    public 
    func contains(_ key:Key) -> Bool 
    {
        self.items.keys.contains(key.stringValue)
    }
    // local `Key` type may be different from the dictionary’s `Key` type
    func diagnose<Key, T>(_ key:Key, _ decode:(JSON) -> (T.Type) throws -> T?) throws -> T
        where Key:CodingKey
    {
        var path:[CodingKey] 
        { 
            self.codingPath + CollectionOfOne<CodingKey>.init(key) 
        }
        guard let value:JSON = items[key.stringValue]
        else 
        {
            let context:DecodingError.Context = .init(codingPath: path, 
                debugDescription: "key '\(key)' not found")
            throw DecodingError.keyNotFound(key, context)
        }
        do 
        {
            if let decoded:T = try decode(value)(T.self)
            {
                return decoded 
            }
        }
        catch let error
        {
            throw JSON.Decoder.error(annotating: error, initializing: T.self, path: path)
        }
        throw JSON.Decoder.error(typecasting: value, to: T.self, path: self.codingPath)
    }
    
    func decodeNil(forKey key:Key) throws -> Bool
    {
        try self.diagnose(key, { `self` in { _ in `self`(is: Void.self) } })
    }
    public
    func decode(_:Bool.Type, forKey key:Key) throws -> Bool
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:Int.Type, forKey key:Key) throws -> Int
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:Int64.Type, forKey key:Key) throws -> Int64
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:Int32.Type, forKey key:Key) throws -> Int32
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:Int16.Type, forKey key:Key) throws -> Int16
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:Int8.Type, forKey key:Key) throws -> Int8
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:UInt.Type, forKey key:Key) throws -> UInt
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:UInt64.Type, forKey key:Key) throws -> UInt64
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:UInt32.Type, forKey key:Key) throws -> UInt32
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:UInt16.Type, forKey key:Key) throws -> UInt16
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:UInt8.Type, forKey key:Key) throws -> UInt8
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:Float.Type, forKey key:Key) throws -> Float
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:Double.Type, forKey key:Key) throws -> Double
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode(_:String.Type, forKey key:Key) throws -> String
    {
        try self.diagnose(key, JSON.callAsFunction(as:))
    }
    public
    func decode<T>(_:T.Type, forKey key:Key) throws -> T where T:Decodable
    {
        return try .init(from: try self.singleValueContainer(forKey: key))
    }
    
    func superDecoder() 
        throws -> Swift.Decoder
    {
        try self.singleValueContainer(forKey: JSON.Key.super, typed: JSON.Key.self)
    }
    public 
    func superDecoder(forKey key:Key) 
        throws -> Swift.Decoder
    {
        try self.singleValueContainer(forKey: key) as Swift.Decoder
    }
    
    public 
    func singleValueContainer(forKey key:Key) 
        throws -> JSON.Decoder
    {
        try self.singleValueContainer(forKey: key, typed: Key.self)
    }
    public 
    func singleValueContainer<Key>(forKey key:Key, typed _:Key.Type) 
        throws -> JSON.Decoder
        where Key:CodingKey
    {
        let value:JSON                          = try self.diagnose(key){ `self` in { _ in `self` } }
        let decoder:JSON.Decoder                = .init(value, 
            path: self.codingPath + CollectionOfOne<CodingKey>.init(key))
        return       decoder
    }
    public 
    func nestedUnkeyedContainer(forKey key:Key) 
        throws -> UnkeyedDecodingContainer
    {
        let elements:[JSON]                     = try self.diagnose(key, JSON.callAsFunction(as:))
        let decoder:JSON.Array                  = .init(elements, 
            path: self.codingPath + CollectionOfOne<CodingKey>.init(key))
        return       decoder as UnkeyedDecodingContainer
    }
    public 
    func nestedContainer<NestedKey>(keyedBy _:NestedKey.Type, forKey key:Key) 
        throws -> KeyedDecodingContainer<NestedKey>
    {
        let decoder:JSON.Dictionary<NestedKey>  = .init(
            try   self.diagnose(key, JSON.callAsFunction(as:)), 
            path: self.codingPath + CollectionOfOne<CodingKey>.init(key))
        {
            (_, overwrite) in overwrite 
        }
        return .init(decoder)
    }
}

extension JSON 
{    
    struct Array
    {
        public 
        let codingPath:[CodingKey]
        public 
        var currentIndex:Int 
        let elements:[JSON]
        
        public 
        init(_ elements:[JSON], path:[CodingKey])
        {
            self.codingPath     = path
            self.currentIndex   = elements.startIndex 
            self.elements       = elements
        }
    }
}
extension JSON.Array:UnkeyedDecodingContainer
{
    public 
    var count:Int?
    {
        self.elements.count
    }
    public 
    var isAtEnd:Bool 
    {
        self.currentIndex >= self.elements.endIndex
    }
    
    mutating 
    func diagnose<T>(_ decode:(JSON) -> (T.Type) throws -> T?) throws -> T
    {
        let key:JSON.Index  = .init(intValue: self.currentIndex) 
        var path:[CodingKey] 
        { 
            self.codingPath + CollectionOfOne<CodingKey>.init(key) 
        }
        
        if self.isAtEnd 
        {
            let context:DecodingError.Context = .init(codingPath: path, 
                debugDescription: "index (\(self.currentIndex)) out of range")
            throw DecodingError.keyNotFound(key, context)
        }
        
        let value:JSON      = self.elements[self.currentIndex]
        self.currentIndex  += 1
        do 
        {
            if let decoded:T = try decode(value)(T.self)
            {
                return decoded 
            }
        }
        catch let error
        {
            throw JSON.Decoder.error(annotating: error, initializing: T.self, path: path)
        }
        throw JSON.Decoder.error(typecasting: value, to: T.self, path: self.codingPath)
    }
    
    public mutating 
    func decodeNil() throws -> Bool
    {
        try self.diagnose{ `self` in { _ in `self`(is: Void.self) } }
    }
    public mutating 
    func decode(_:Bool.Type) throws -> Bool
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:Int.Type) throws -> Int
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:Int64.Type) throws -> Int64
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:Int32.Type) throws -> Int32
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:Int16.Type) throws -> Int16
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:Int8.Type) throws -> Int8
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:UInt.Type) throws -> UInt
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:UInt64.Type) throws -> UInt64
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:UInt32.Type) throws -> UInt32
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:UInt16.Type) throws -> UInt16
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:UInt8.Type) throws -> UInt8
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:Float.Type) throws -> Float
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:Double.Type) throws -> Double
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode(_:String.Type) throws -> String
    {
        try self.diagnose(JSON.callAsFunction(as:))
    }
    public mutating 
    func decode<T>(_:T.Type) throws -> T where T:Decodable
    {
        try .init(from: try self.singleValueContainer())
    }
    public mutating  
    func superDecoder() 
        throws -> Decoder
    {
        try self.singleValueContainer()
    }
    public mutating 
    func singleValueContainer() 
        throws -> JSON.Decoder
    {
        let key:JSON.Index                      = .init(intValue: self.currentIndex) 
        let value:JSON                          = try self.diagnose { `self` in { _ in `self` } }
        let decoder:JSON.Decoder                = .init(value, 
            path: self.codingPath + CollectionOfOne<CodingKey>.init(key))
        return       decoder
    }
    public mutating 
    func nestedUnkeyedContainer() 
        throws -> UnkeyedDecodingContainer
    {
        let key:JSON.Index                      = .init(intValue: self.currentIndex) 
        let elements:[JSON]                     = try self.diagnose(JSON.callAsFunction(as:))
        let decoder:JSON.Array                  = .init(elements, 
            path: self.codingPath + CollectionOfOne<CodingKey>.init(key))
        return       decoder as UnkeyedDecodingContainer
    }
    public mutating 
    func nestedContainer<NestedKey>(keyedBy _:NestedKey.Type) 
        throws -> KeyedDecodingContainer<NestedKey>
    {
        let key:JSON.Index                      = .init(intValue: self.currentIndex) 
        let decoder:JSON.Dictionary<NestedKey>  = .init(
            try   self.diagnose(JSON.callAsFunction(as:)), 
            path: self.codingPath + CollectionOfOne<CodingKey>.init(key))
        {
            (_, overwrite) in overwrite
        }
        return .init(decoder)
    }
}
