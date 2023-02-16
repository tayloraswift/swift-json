// primitive decoding hooks (optional, does not include null)
extension JSON
{
    @available(*, deprecated, renamed: "as(cases:)")
    @inlinable public
    func `case`<T>(of _:T.Type) throws -> T 
        where T:RawRepresentable, T.RawValue == String
    {
        try self.as(cases: T.self)
    }
    /// Attempts to load an instance of some ``String``-backed type from this variant.
    @inlinable public
    func `as`<StringCoded>(cases _:StringCoded.Type) throws -> StringCoded 
        where StringCoded:RawRepresentable, StringCoded.RawValue == String
    {
        if let value:StringCoded = StringCoded.init(rawValue: try self.as(String.self))
        {
            return value
        }
        else 
        {
            throw PrimitiveError.matching(variant: self, as: StringCoded.self)
        }
    }
    /// Attempts to load an instance of some ``Character``-backed type from this variant.
    @inlinable public
    func `as`<CharacterCoded>(cases _:CharacterCoded.Type) throws -> CharacterCoded 
        where CharacterCoded:RawRepresentable, CharacterCoded.RawValue == Character
    {
        let string:String = try self.as(String.self)

        if  let character:Character = string.first, string.dropFirst().isEmpty,
            let value:CharacterCoded = CharacterCoded.init(rawValue: character)
        {
            return value
        }
        else 
        {
            throw PrimitiveError.matching(variant: self, as: CharacterCoded.self)
        }
    }
    /// Attempts to load an instance of some ``Unicode/Scalar``-backed type from this variant.
    @inlinable public
    func `as`<ScalarCoded>(cases _:ScalarCoded.Type) throws -> ScalarCoded 
        where ScalarCoded:RawRepresentable, ScalarCoded.RawValue == Unicode.Scalar
    {
        let scalars:String.UnicodeScalarView = try self.as(String.self).unicodeScalars

        if  let scalar:Unicode.Scalar = scalars.first, scalars.dropFirst().isEmpty,
            let value:ScalarCoded = ScalarCoded.init(rawValue: scalar)
        {
            return value
        }
        else 
        {
            throw PrimitiveError.matching(variant: self, as: ScalarCoded.self)
        }
    }
    /// Attempts to load an instance of some ``SignedInteger``-backed type from this variant.
    @inlinable public
    func `as`<IntegerCoded>(cases _:IntegerCoded.Type) throws -> IntegerCoded 
        where   IntegerCoded:RawRepresentable, 
                IntegerCoded.RawValue:FixedWidthInteger & SignedInteger
    {
        if  let value:IntegerCoded = IntegerCoded.init(
                rawValue: try self.as(IntegerCoded.RawValue.self))
        {
            return value
        }
        else 
        {
            throw PrimitiveError.matching(variant: self, as: IntegerCoded.self)
        }
    }
    /// Attempts to load an instance of some ``UnsignedInteger``-backed type from this variant.
    @inlinable public
    func `as`<UnsignedIntegerCoded>(cases _:UnsignedIntegerCoded.Type) throws -> UnsignedIntegerCoded 
        where   UnsignedIntegerCoded:RawRepresentable, 
                UnsignedIntegerCoded.RawValue:FixedWidthInteger & UnsignedInteger
    {
        if  let value:UnsignedIntegerCoded = UnsignedIntegerCoded.init(
                rawValue: try self.as(UnsignedIntegerCoded.RawValue.self))
        {
            return value
        }
        else 
        {
            throw PrimitiveError.matching(variant: self, as: UnsignedIntegerCoded.self)
        }
    }

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
    /// Attempts to unwrap an explicit ``null`` from this variant.
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
    /// Attempts to unwrap an instance of ``Bool`` from this variant.
    /// 
    /// - Returns: The payload of this variant if it matches ``bool(_:)``, 
    ///     [`nil`]() otherwise.
    // @inlinable public 
    // func `as`(_:Bool.Type) -> Bool?
    // {
    //     switch self 
    //     {
    //     case .bool(let value):  return value
    //     default:                return nil 
    //     }
    // }
    
    /// Attempts to unwrap an instance of ``String`` from this variant.
    /// 
    /// - Returns: The payload of this variant if it matches ``string(_:)``, 
    ///     [`nil`]() otherwise.
    /// >   Complexity: 
    ///     O(1). This method does *not* perform any character-wise work.
    // @inlinable public 
    // func `as`(_:String.Type) -> String?
    // {
    //     switch self 
    //     {
    //     case .string(let string):   return string
    //     default:                    return nil
    //     }
    // }
    /// Attempts to unwrap an ``Array`` of [`Self`]() from this variant.
    /// 
    /// - Returns: The payload of this variant if it matches ``array(_:)``, 
    ///     [`nil`]() otherwise.
    /// >   Complexity: 
    //      O(1). This method does *not* perform any elementwise work.
    // @inlinable public 
    // func `as`(_:[Self].Type) -> [Self]?
    // {
    //     switch self 
    //     {
    //     case .array(let elements):  return elements 
    //     default:                    return nil
    //     }
    // }
    

    /// Attempts to load a ``Dictionary`` from this variant, de-duplicating keys 
    /// with the given closure.
    /// 
    /// - Returns: A dictionary derived from the payload of this variant if it 
    ///     matches ``object(_:)``, the fields of the payload of this variant if 
    ///     it matches ``number(_:)?overload=s4JSONAAO6numberyA2B6NumberVcABmF``, 
    ///     or [`nil`]() otherwise.
    /// 
    /// Although it is uncommon in real-world JSON APIs, object keys can occur 
    /// more than once in the same object. To handle this, an API consumer might 
    /// elect to keep only the last occurrence of a particular key.
    ///
    /// ```swift 
    /// let dictionary:[String: JSON]? = json.as([String: JSON].self) { $1 }
    /// ```
    ///
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
        try self.object.map
        {
            try [String: Self].init($0, uniquingKeysWith: combine)
        }
    }
}
// primitive decoding hooks (throws, does not include null)
extension JSON
{
    @available(*, deprecated, renamed: "match(_:)")
    @inlinable public 
    func unwrap<T>(pattern:(Self) -> (T.Type) throws -> T?) throws -> T
    {
        try self.match(pattern)
    }
    /// Promotes a [`nil`]() result to a thrown ``PrimitiveError``.
    /// 
    /// >   Throws: A ``PrimitiveError.matching(variant:as:)`` if the given 
    ///     curried method returns [`nil`]().
    @inline(__always)
    @inlinable public 
    func match<T>(_ pattern:(Self) -> (T.Type) throws -> T?) throws -> T
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
    /// Attempts to unwrap an explicit ``null`` from this variant.
    /// 
    /// This method is a throwing variation of ``as(_:)?overload=s4JSONAAO2asyytSgytmF``.
    @inlinable public 
    func `as`(_:Void.Type) throws 
    {
        try self.match(Self.as(_:)) as Void
    }
    
    /// Attempts to unwrap a fixed-length ``Array`` of [`Self`]() from this variant.
    /// 
    /// - Returns: The payload of this variant if it matches ``array(_:)``, and 
    ///     contains the expected number of elements.
    /// 
    /// >   Complexity: O(1). This method does *not* perform any elementwise work.
    ///
    /// >   Throws: A ``PrimitiveError.shaping(aggregate:count:)`` if an array was 
    ///     successfully unwrapped, but it did not contain the expected number of 
    ///     elements.
    @inlinable public 
    func `as`(_:[Self].Type, count:Int) throws -> [Self]
    {
        let aggregate:[Self] = try self.match(Self.as(_:))
        if  aggregate.count == count 
        {
            return aggregate
        }
        else 
        {
            throw PrimitiveError.shaping(aggregate: aggregate, count: count)
        }
    }
    /// Attempts to unwrap an ``Array`` of [`Self`]() from this variant, whose length 
    /// satifies the given criteria.
    /// 
    /// - Returns: The payload of this variant if it matches ``array(_:)``, and 
    ///     contains the expected number of elements.
    /// 
    /// >   Complexity: O(1). This method does *not* perform any elementwise work.
    ///
    /// >   Throws: A ``PrimitiveError.shaping(aggregate:count:)`` if an array was 
    ///     successfully unwrapped, but it did not contain the expected number of 
    ///     elements.
    @inlinable public 
    func `as`(_:[Self].Type, where predicate:(_ count:Int) throws -> Bool) throws -> [Self]
    {
        let aggregate:[Self] = try self.match(Self.as(_:))
        if try predicate(aggregate.count)
        {
            return aggregate
        }
        else 
        {
            throw PrimitiveError.shaping(aggregate: aggregate)
        }
    }
    /// Attempts to load a ``Dictionary`` from this variant, de-duplicating keys 
    /// with the given closure.
    /// 
    /// This method is a throwing variation of 
    /// ``as(_:uniquingKeysWith:)?overload=s4JSONAAO2as_16uniquingKeysWithSDySSABGSgAEm_A2B_ABtKXEtKF``.
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
    @available(*, deprecated, renamed: "flatMatch(_:)")
    @inlinable public 
    func apply<T>(pattern:(Self) -> (T.Type) throws -> T?) throws -> T?
    {
        try self.flatMatch(pattern)
    }

    /// Promotes a [`nil`]() result to a thrown ``PrimitiveError``, if this variant 
    /// is not an explicit ``null``.
    /// 
    /// `flatMatch(_:)` is to ``match(_:)`` what ``Optional.flatMap(_:)`` is to 
    /// ``Optional.map(_:)``.
    /// 
    /// -   Returns: [`nil`]() if this variant is an explicit ``null``; the result of 
    ///     applying the given curried method otherwise.
    /// 
    /// >   Throws: A ``PrimitiveError.matching(variant:as:)`` if the given 
    ///     curried method returns [`nil`]().
    @inline(__always)
    @inlinable public 
    func flatMatch<T>(_ pattern:(Self) -> (T.Type) throws -> T?) throws -> T?
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
    /// Attempts to unwrap a fixed-length ``Array`` of [`Self`]() or an explicit ``null`` 
    /// from this variant.
    /// 
    /// This method is an optionalized variation of 
    /// ``as(_:count:)?overload=s4JSONAAO2as_5countSayABGAEm_SitKF``.
    @inlinable public 
    func `as`(_:[Self]?.Type, count:Int) throws -> [Self]?
    {
        guard let aggregate:[Self] = try self.flatMatch(Self.as(_:))
        else 
        {
            return nil
        }
        if  aggregate.count == count 
        {
            return aggregate
        }
        else 
        {
            throw PrimitiveError.shaping(aggregate: aggregate, count: count)
        }
    }
    /// Attempts to unwrap an ``Array`` of [`Self`]() from this variant, whose length 
    /// satifies the given criteria, or an explicit ``null``.
    /// 
    /// This method is an optionalized variation of 
    /// ``as(_:where:)?overload=s4JSONAAO2as_5whereSayABGAEm_SbSiKXEtKF``.
    @inlinable public 
    func `as`(_:[Self]?.Type, where predicate:(_ count:Int) throws -> Bool) throws -> [Self]?
    {
        guard let aggregate:[Self] = try self.flatMatch(Self.as(_:))
        else 
        {
            return nil
        }
        if try predicate(aggregate.count)
        {
            return aggregate
        }
        else 
        {
            throw PrimitiveError.shaping(aggregate: aggregate)
        }
    }
    /// Attempts to load a ``Dictionary`` from this variant, de-duplicating keys 
    /// with the given closure.
    /// 
    /// This method is an optionalized variation of 
    /// ``as(_:uniquingKeysWith:)?overload=s4JSONAAO2as_16uniquingKeysWithSDySSABGAEm_A2B_ABtKXEtKF``.
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

extension JSON 
{
    @inlinable public 
    func `as`(_:Bool.Type) throws -> Bool
    {
        try self.match(Self.as(_:))
    }
    @inlinable public 
    func `as`(_:Bool?.Type) throws -> Bool?
    {
        try self.flatMatch(Self.as(_:))
    }
}

extension JSON 
{
    @inlinable public 
    func `as`(_:String.Type) throws -> String
    {
        try self.match(Self.as(_:))
    }
    @inlinable public 
    func `as`(_:String?.Type) throws -> String?
    {
        try self.flatMatch(Self.as(_:))
    }
}

extension JSON 
{
    @inlinable public 
    func `as`(_:[Self].Type) throws -> [Self]
    {
        try self.match(Self.as(_:))
    }
    @inlinable public 
    func `as`(_:[Self]?.Type) throws -> [Self]?
    {
        try self.flatMatch(Self.as(_:))
    }
}

extension JSON 
{
    @inlinable public 
    func `as`(_:[(key:String, value:Self)].Type) throws -> [(key:String, value:Self)]
    {
        try self.match(Self.as(_:))
    }
    @inlinable public 
    func `as`(_:[(key:String, value:Self)]?.Type) throws -> [(key:String, value:Self)]?
    {
        try self.flatMatch(Self.as(_:))
    }
}

extension JSON 
{
    @inlinable public 
    func `as`<Integer>(_:Integer.Type) throws -> Integer
        where Integer:FixedWidthInteger & SignedInteger
    {
        try self.match(Self.as(_:))
    }
    @inlinable public 
    func `as`<Integer>(_:Integer?.Type) throws -> Integer? 
        where Integer:FixedWidthInteger & SignedInteger
    {
        try self.flatMatch(Self.as(_:))
    }
}

extension JSON 
{
    @inlinable public 
    func `as`<Integer>(_:Integer.Type) throws -> Integer
        where Integer:FixedWidthInteger & UnsignedInteger
    {
        try self.match(Self.as(_:))
    }
    @inlinable public 
    func `as`<Integer>(_:Integer?.Type) throws -> Integer? 
        where Integer:FixedWidthInteger & UnsignedInteger
    {
        try self.flatMatch(Self.as(_:))
    }
}

extension JSON 
{
    @inlinable public 
    func `as`<Binary>(_:Binary.Type) throws -> Binary
        where Binary:BinaryFloatingPoint
    {
        try self.match(Self.as(_:))
    }
    @inlinable public 
    func `as`<Binary>(_:Binary?.Type) throws -> Binary? 
        where Binary:BinaryFloatingPoint
    {
        try self.flatMatch(Self.as(_:))
    }
}