extension JSON 
{
    /// A lossless representation of a numeric literal.
    ///
    /// This type is memory-efficient, and can store fixed-point numbers with 
    /// up to 64 bits of precision. It uses all 64 bits to encode its magnitude, 
    /// which enables it to round-trip integers of width up to ``UInt64``.
    @frozen public 
    struct Number:Hashable, Equatable, Sendable
    {
        // this layout should allow instances of `Number` to fit in 2 words.
        // this is backed by an `Int`, but the swift compiler can optimize it 
        // into a `UInt8`-sized field
        
        /// The sign of this numeric literal.
        public 
        var sign:FloatingPointSign 
        // cannot have an inlinable property wrapper
        @usableFromInline internal 
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
        init(sign:FloatingPointSign, units:UInt64, places:UInt32 = 0)
        {
            self.sign       = sign 
            self.units      = units 
            self._places    = places
        }
    }
}
extension JSON.Number
{
    @inlinable public 
    init<T>(_ signed:T) where T:SignedInteger 
    {
        self.init(sign: signed < 0 ? .minus : .plus, units: UInt64.init(signed.magnitude))
    }
    @inlinable public 
    init<T>(_ unsigned:T) where T:UnsignedInteger 
    {
        self.init(sign: .plus, units: UInt64.init(unsigned))
    }
}
extension JSON.Number
{
    /// Converts this numeric literal to an unsigned integer, if it can be 
    /// represented exactly.
    /// -   Parameters:
    ///     - _: A type conforming to ``UnsignedInteger`` (and ``FixedWidthInteger``).
    /// -   Returns: 
    ///     The value of this numeric literal as an instance of [`T`](), or 
    ///     [`nil`]() if it is negative, fractional, or would overflow [`T`]().
    /// >   Note:
    ///     This type conversion will fail if ``places`` is non-zero, even if 
    ///     the fractional part is zero. For example, you can convert 
    ///     [`5`]() to an integer, but not [`5.0`](). This matches the behavior 
    ///     of ``ExpressibleByIntegerLiteral``.
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
    /// >   Note:
    ///     This type conversion will fail if ``places`` is non-zero, even if 
    ///     the fractional part is zero. For example, you can convert 
    ///     [`5`]() to an integer, but not [`5.0`](). This matches the behavior 
    ///     of ``ExpressibleByIntegerLiteral``.
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
    /// >   Note: 
    ///     It’s possible for the `places` field to overflow before `units` does.
    ///     For example, this will happen for the literal [`"0.0e-9999999999999999999"`]().
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

    //  Note: There is currently a compiler crash
    //
    //      https://github.com/apple/swift/issues/63775
    //
    //  that prevents ``nearest(_:)`` from being inlined into clients,
    //  because it uses a lookup table for negative powers of ten.
    //  Therefore, we provide manual specializations for ``Float80``,
    //  ``Double``, and ``Float`` instead. On the bright side, this
    //  means we don’t need to emit a giant conversion function into
    //  the client. (We just have three giant conversion function
    //  specializations in the library.)
    #if (os(Linux) || os(macOS)) && arch(x86_64)
    /// Converts this numeric literal to a ``Float80`` value, or its closest 
    /// floating-point representation.
    public
    func `as`(_:Float80.Type) -> Float80
    {
        self.nearest(Float80.self)
    }
    #endif
    /// Converts this numeric literal to a ``Double`` value, or its closest 
    /// floating-point representation.
    public
    func `as`(_:Double.Type) -> Double
    {
        self.nearest(Double.self)
    }
    /// Converts this numeric literal to a ``Float`` value, or its closest 
    /// floating-point representation.
    public
    func `as`(_:Float.Type) -> Float
    {
        self.nearest(Float.self)
    }

    /// Converts this numeric literal to a floating-point value, or its closest 
    /// floating-point representation.
    ///
    /// -   Parameters:
    ///     - _: A type conforming to ``BinaryFloatingPoint``.
    /// -   Returns: 
    ///     The value of this numeric literal as an instance of 
    ///     [`T`](), or the value of [`T`]() closest to it.
    private
    func nearest<T>(_:T.Type) -> T where T:BinaryFloatingPoint 
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
extension JSON.Number:CustomStringConvertible
{
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
        let string:String   =
        """
        \(String.init(repeating: "0", count: Swift.max(0, 1 + places - unpadded.count)))\
        \(unpadded)
        """
        switch self.sign 
        {
        case .plus:     return  "\(string.dropLast(places)).\(string.suffix(places))"
        case .minus:    return "-\(string.dropLast(places)).\(string.suffix(places))"
        }
    }
}
