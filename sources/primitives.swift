// primitive decoding hooks (optional)
extension JSON
{
    @_spi(experimental) @inlinable public 
    func `is`(_:Void.Type) -> Bool
    {
        switch self 
        {
        case .null: return true 
        default:    return false
        }
    }
    @_spi(experimental) @inlinable public 
    func `as`(_:Void?.Type) -> Void?
    {
        switch self 
        {
        case .null: return ()
        default:    return nil 
        }
    }
    @_spi(experimental) @inlinable public 
    func `as`(explicit _:Bool?.Type) -> Bool?
    {
        switch self 
        {
        case .bool(let value):  return value
        default:                return nil 
        }
    }
    // this still throws, but not because of a type mismatch
    @_spi(experimental) @inlinable public 
    func `as`<T>(explicit _:T?.Type) throws -> T? 
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
    @_spi(experimental) @inlinable public 
    func `as`<T>(explicit _:T?.Type) throws -> T?
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
    @_spi(experimental) @inlinable public 
    func `as`<T>(explicit _:T?.Type) -> T?
        where T:BinaryFloatingPoint
    {
        switch self 
        {
        case .number(let number):   return number(as: T.self)
        default:                    return nil 
        }
    }
    @_spi(experimental) @inlinable public 
    func `as`(explicit _:String?.Type) -> String?
    {
        switch self 
        {
        case .string(let string):   return string
        default:                    return nil
        }
    }
    @_spi(experimental) @inlinable public 
    func `as`(explicit _:[Self]?.Type) -> [Self]?
    {
        switch self 
        {
        case .array(let elements):  return elements 
        default:                    return nil
        }
    }
    
    @available(*, unavailable, message: "handle duplicate keys explicitly with `as(explicit:uniquingKeysWith:)`")
    func `as`(explicit _:[String: Self]?.Type) -> [String: Self]? 
    {
        self.as(explicit: [String: Self]?.self) { $1 }
    }
    @_spi(experimental) @inlinable public 
    func `as`(explicit _:[(key:String, value:Self)]?.Type) -> [(key:String, value:Self)]? 
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
    @_spi(experimental) @inlinable public 
    func `as`(explicit _:[String: Self]?.Type, 
        uniquingKeysWith combine:(Self, Self) throws -> Self) rethrows -> [String: Self]? 
    {
        try self.as(explicit: [(key:String, value:Self)]?.self).map
        {
            try [String: Self].init($0, uniquingKeysWith: combine)
        }
    }
}
