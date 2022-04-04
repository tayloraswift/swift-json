// primitive decoding hooks (optional, does not include null)
extension JSON
{
    /// Indicates if this variant is ``null``.
    @inlinable public 
    func `is`(_:Void.Type) -> Bool
    {
        switch self 
        {
        case .null: return true 
        default:    return false
        }
    }
    /// Attempts to cast this variant to an instance of ``Void``.
    /// 
    /// - returns: [`()`]() if this variant is ``null``, [`nil`]() otherwise.
    @inlinable public 
    func `as`(_:Void.Type) -> Void?
    {
        switch self 
        {
        case .null: return ()
        default:    return nil 
        }
    }
    /// Attempts to cast this variant to an instance of ``Bool``.
    /// 
    /// - Returns: The payload of this variant if it matches ``bool(_:)``, 
    ///     [`nil`]() otherwise.
    @inlinable public 
    func `as`(_:Bool.Type) -> Bool?
    {
        switch self 
        {
        case .bool(let value):  return value
        default:                return nil 
        }
    }
    /// Attempts to cast this variant to an instance of a ``SignedInteger`` type.
    /// 
    /// - Returns: A signed integer derived from the payload of this variant
    ///     if it matches ``number(_:)``, and it can be represented exactly by [`T`]();
    ///     [`nil`]() otherwise.
    ///
    /// This method reports failure in two ways — it returns [`nil`]() on a type 
    /// mismatch, and it [`throws`]() an ``IntegerOverflowError`` if this variant 
    /// matches ``number(_:)``, but it could not be represented exactly by [`T`]().
    /// >   Note:
    ///     This type conversion will fail if ``Number.places`` is non-zero, even if 
    ///     the fractional part is zero. For example, you can convert 
    ///     [`5`]() to an integer, but not [`5.0`](). This matches the behavior 
    ///     of ``ExpressibleByIntegerLiteral``.
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
    /// Attempts to cast this variant to an instance of an ``UnsignedInteger`` type.
    /// 
    /// - Returns: An unsigned integer derived from the payload of this variant
    ///     if it matches ``number(_:)``, and it can be represented exactly by [`T`]();
    ///     [`nil`]() otherwise.
    ///
    /// This method reports failure in two ways — it returns [`nil`]() on a type 
    /// mismatch, and it [`throws`]() an ``IntegerOverflowError`` if this variant 
    /// matches ``number(_:)``, but it could not be represented exactly by [`T`]().
    /// >   Note:
    ///     This type conversion will fail if ``Number.places`` is non-zero, even if 
    ///     the fractional part is zero. For example, you can convert 
    ///     [`5`]() to an integer, but not [`5.0`](). This matches the behavior 
    ///     of ``ExpressibleByIntegerLiteral``.
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
    /// Attempts to cast this variant to an instance of a ``BinaryFloatingPoint`` type.
    /// 
    /// - Returns: The closest value of [`T`]() to the payload of this 
    ///     variant if it matches ``number(_:)``, [`nil`]() otherwise.
    ///
    /// Calling this method is equivalent to matching the ``number(_:)`` enumeration 
    /// case, and calling ``Number.as(_:)`` on its payload.
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
    /// Attempts to cast this variant to an instance of ``String``.
    /// 
    /// - Returns: The payload of this variant if it matches ``string(_:)``, 
    ///     [`nil`]() otherwise.
    /// >   Complexity: 
    ///     O(1). This method does *not* perform any character-wise work.
    @inlinable public 
    func `as`(_:String.Type) -> String?
    {
        switch self 
        {
        case .string(let string):   return string
        default:                    return nil
        }
    }
    /// Attempts to cast this variant to an ``Array`` of [`Self`]().
    /// 
    /// - Returns: The payload of this variant if it matches ``array(_:)``, 
    ///     [`nil`]() otherwise.
    /// >   Complexity: 
    //      O(1). This method does *not* perform any elementwise work.
    @inlinable public 
    func `as`(_:[Self].Type) -> [Self]?
    {
        switch self 
        {
        case .array(let elements):  return elements 
        default:                    return nil
        }
    }
    
    /// Attempts to cast this variant to an ``Array`` of key-value pairs.
    /// 
    /// - Returns: The payload of this variant if it matches ``object(_:)``, 
    ///     the fields of the payload of this variant if it matches ``number(_:)``, or
    ///     [`nil`]() otherwise.
    /// 
    /// The order of the items reflects the order in which they appear in the 
    /// source object. For more details about the payload, see the documentation 
    /// for ``object(_:)``.
    /// 
    /// To facilitate interoperability with decimal types, this method will also 
    /// return a pseudo-object containing the values of ``Number.units`` and ``Number.places``, 
    /// if this variant is a ``number(_:)``. Specifically, it contains integral 
    /// ``Number`` values keyed by [`"units"`]() and [`"places"`]() and wrapped 
    /// in containers of type [`Self`]().
    ///
    /// This pseudo-object is intended for consumption by compiler-generated 
    /// ``Codable`` implementations. Decoding it incurs a small but non-zero 
    /// overhead when compared with calling ``Number.as(_:)`` directly.
    /// 
    /// >   Complexity: 
    ///     O(1). This method does *not* perform any elementwise work.
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
    /// Attempts to cast this variant to a ``Dictionary`` of [`Self`]().
    /// 
    /// - Returns: A dictionary derived from the payload of this variant if it 
    ///     matches ``object(_:)``, the fields of the payload of this variant if 
    ///     it matches ``number(_:)``, or [`nil`]() otherwise.
    /// 
    /// Although it is uncommon in real-world JSON APIs, object keys can occur 
    /// more than once in the same object. To handle this, an API consumer might 
    /// elect to keep only the last occurrence of a particular key.
    /**
    ```swift 
    let dictionary:[String: JSON]? = json.as([String: JSON].self) { $1 }
    ```
    */
    /// Key duplication can interact with unicode normalization in unexpected 
    /// ways. Because JSON is defined in UTF-8, other JSON encoders may not align 
    /// with the behavior of ``String.==(_:_:)``, since that operator 
    /// compares grapheme clusters and not UTF-8 code units. 
    /// 
    /// For example, if an object vends separate keys for [`"\u{E9}"`]() ([`"é"`]()) and 
    /// [`"\u{65}\u{301}"`]() (also [`"é"`](), perhaps, because the object is 
    /// being used to bootstrap a unicode table), uniquing them by ``String`` 
    /// comparison will drop one of the values.
    ///
    /// Calling this method is equivalent to calling ``as(_:)``, and chaining its 
    /// optional result through ``Dictionary.init(_:uniquingKeysWith:)``. See the 
    /// documentation for ``as(_:)`` for more details about the behavior of this method.
    /// 
    /// >   Complexity: 
    ///     O(*n*), where *n* is the number of items in the object. 
    ///     This method does *not* perform any recursive work.
    ///
    /// >   Warning: 
    ///     When you convert an object to a dictionary representation, you lose the ordering 
    ///     information for the object items. Reencoding it may produce a JSON 
    ///     message that contains the same data, but does not compare equal under 
    ///     a string- or byte-comparison.
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
