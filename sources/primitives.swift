// primitive decoding hooks (optional, does not include null)
extension JSON
{
    @inlinable public 
    func `is`(_:Void.Type) -> Bool
    {
        switch self 
        {
        case .null: return true 
        default:    return false
        }
    }
    @inlinable public 
    func `as`(_:Void.Type) -> Void?
    {
        switch self 
        {
        case .null: return ()
        default:    return nil 
        }
    }
    @inlinable public 
    func `as`(_:Bool.Type) -> Bool?
    {
        switch self 
        {
        case .bool(let value):  return value
        default:                return nil 
        }
    }
    // this still throws, but not because of a type mismatch
    @inlinable public 
    func `as`<T>(_:T.Type) throws -> T? 
        where T:FixedWidthInteger & SignedInteger
    {
        // do not use init(exactly:) with decimal value directly, as this 
        // will also accept values like 1.0, which we want to reject
        guard case .number(let number) = self 
        else 
        {
            return nil
        }
        guard let integer:T = number.as(T.self)
        else 
        {
            throw IntegerOverflowError.init(number: number, overflows: T.self)
        }
        return integer 
    }
    @inlinable public 
    func `as`<T>(_:T.Type) throws -> T?
        where T:FixedWidthInteger & UnsignedInteger
    {
        guard case .number(let number) = self 
        else 
        {
            return nil
        }
        guard let integer:T = number.as(T.self)
        else 
        {
            throw IntegerOverflowError.init(number: number, overflows: T.self)
        }
        return integer 
    }
    @inlinable public 
    func `as`<T>(_:T.Type) -> T?
        where T:BinaryFloatingPoint
    {
        switch self 
        {
        case .number(let number):   return number.as(T.self)
        default:                    return nil 
        }
    }
    @inlinable public 
    func `as`(_:String.Type) -> String?
    {
        switch self 
        {
        case .string(let string):   return string
        default:                    return nil
        }
    }
    @inlinable public 
    func `as`(_:[Self].Type) -> [Self]?
    {
        switch self 
        {
        case .array(let elements):  return elements 
        default:                    return nil
        }
    }
    
    /* @_disfavoredOverload
    @available(*, unavailable, message: "handle duplicate keys explicitly with `as(_:uniquingKeysWith:)`")
    public 
    func `as`(_:[String: Self].Type) -> [String: Self]? 
    {
        self.as([String: Self].self) { $1 }
    } */
    @inlinable public 
    func `as`(_:[(key:String, value:Self)].Type) -> [(key:String, value:Self)]? 
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
    @inlinable public 
    func `as`(_:[String: Self].Type, 
        uniquingKeysWith combine:(Self, Self) throws -> Self) rethrows -> [String: Self]? 
    {
        try self.as([(key:String, value:Self)].self).map
        {
            try [String: Self].init($0, uniquingKeysWith: combine)
        }
    }
}
// primitive decoding hooks (throws, does not include null)
extension JSON
{    
    @inline(__always)
    @inlinable public 
    func apply<T>(pattern:(Self) -> (T.Type) throws -> T?) throws -> T
    {
        if let value:T = try pattern(self)(T.self)
        {
            return value 
        }
        else 
        {
            throw PrimitiveError.matching(variant: self, as: T.self)
        }
    }
    @inlinable public 
    func `as`(_:Void.Type) throws 
    {
        try self.apply(pattern: Self.as(_:)) as Void
    }
    @inlinable public 
    func `as`(_:Bool.Type) throws -> Bool
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`<T>(_:T.Type) throws -> T
        where T:FixedWidthInteger & SignedInteger
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`<T>(_:T.Type) throws -> T
        where T:FixedWidthInteger & UnsignedInteger
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`<T>(_:T.Type) throws -> T
        where T:BinaryFloatingPoint
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`(_:String.Type) throws -> String
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`(_:[Self].Type) throws -> [Self]
    {
        try self.apply(pattern: Self.as(_:))
    }

    @inlinable public 
    func `as`(_:[(key:String, value:Self)].Type) throws -> [(key:String, value:Self)]
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`(_:[String: Self].Type, 
        uniquingKeysWith combine:(Self, Self) throws -> Self) throws -> [String: Self]
    {
        try [String: Self].init(try self.as([(key:String, value:Self)].self), 
            uniquingKeysWith: combine)
    }
} 
// primitive decoding hooks (throws, includes null)
extension JSON
{
    @inline(__always)
    @inlinable public 
    func apply<T>(pattern:(Self) -> (T.Type) throws -> T?) throws -> T?
    {
        if case .null = self 
        {
            return nil 
        }
        else if let value:T = try pattern(self)(T.self)
        {
            return value 
        }
        else 
        {
            throw PrimitiveError.matching(variant: self, as: T?.self)
        }
    }
    @inlinable public 
    func `as`(_:Bool?.Type) throws -> Bool?
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`<T>(_:T?.Type) throws -> T? 
        where T:FixedWidthInteger & SignedInteger
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`<T>(_:T?.Type) throws -> T?
        where T:FixedWidthInteger & UnsignedInteger
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`<T>(_:T?.Type) throws -> T?
        where T:BinaryFloatingPoint
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`(_:String?.Type) throws -> String?
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`(_:[Self]?.Type) throws -> [Self]?
    {
        try self.apply(pattern: Self.as(_:))
    }

    @inlinable public 
    func `as`(_:[(key:String, value:Self)]?.Type) throws -> [(key:String, value:Self)]? 
    {
        try self.apply(pattern: Self.as(_:))
    }
    @inlinable public 
    func `as`(_:[String: Self]?.Type, 
        uniquingKeysWith combine:(Self, Self) throws -> Self) throws -> [String: Self]? 
    {
        try self.as([(key:String, value:Self)]?.self).map 
        {
            try [String: Self].init($0, uniquingKeysWith: combine)
        }
    }
} 
