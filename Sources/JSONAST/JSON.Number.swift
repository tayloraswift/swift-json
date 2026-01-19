extension JSON {
    /// A lossless representation of a numeric literal.
    @frozen public enum Number: Hashable, Equatable, Sendable {
        case fallback(String)
        case infinity(FloatingPointSign)
        case inline(Inline)
        case nan
        case snan
    }
}
extension JSON.Number: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .fallback(let string): string
        case .infinity(.plus): "inf"
        case .infinity(.minus): "-inf"
        case .inline(let self): "\(self)"
        case .nan: "nan"
        case .snan: "snan"
        }
    }
}
extension JSON.Number {
    @inlinable public init<T>(_ value: T) where T: SignedInteger {
        self = .inline(.init(value))
    }
    @inlinable public init<T>(_ value: T) where T: UnsignedInteger {
        self = .inline(.init(value))
    }
    @inlinable public init<T>(
        _ value: T
    ) where T: BinaryFloatingPoint & LosslessStringConvertible {
        // must check this first, because `isNaN` is true for signaling NaN as well
        if  value.isSignalingNaN {
            self = .snan
        } else if value.isNaN {
            self = .nan
        } else if value.isInfinite {
            self = .infinity(value.sign)
        } else {
            self = .fallback("\(value)")
        }
    }
}
extension JSON.Number {
    /// Converts this numeric literal to an unsigned integer, if it can be
    /// represented exactly.
    /// -   Parameters:
    ///     - _: A type conforming to ``UnsignedInteger`` (and ``FixedWidthInteger``).
    /// -   Returns:
    ///     The value of this numeric literal as an instance of [`T`](), or
    ///     nil if it is negative, fractional, or would overflow [`T`]().
    /// >   Note:
    ///     This type conversion will fail if ``places`` is non-zero, even if
    ///     the fractional part is zero. For example, you can convert
    ///     [`5`]() to an integer, but not [`5.0`](). This matches the behavior
    ///     of ``ExpressibleByIntegerLiteral``.
    @inlinable public func `as`<T>(
        _: T.Type
    ) -> T? where T: FixedWidthInteger & UnsignedInteger {
        guard case .inline(let self) = self else {
            return nil
        }
        return self.as(T.self)
    }
    /// Converts this numeric literal to a signed integer, if it can be
    /// represented exactly.
    /// -   Parameters:
    ///     - _: A type conforming to ``SignedInteger`` (and ``FixedWidthInteger``).
    /// -   Returns:
    ///     The value of this numeric literal as an instance of [`T`](), or
    ///     nil if it is fractional or would overflow [`T`]().
    /// >   Note:
    ///     This type conversion will fail if ``places`` is non-zero, even if
    ///     the fractional part is zero. For example, you can convert
    ///     [`5`]() to an integer, but not [`5.0`](). This matches the behavior
    ///     of ``ExpressibleByIntegerLiteral``.
    @inlinable public func `as`<T>(
        _: T.Type
    ) -> T? where T: FixedWidthInteger & SignedInteger {
        guard case .inline(let self) = self else {
            return nil
        }
        return self.as(T.self)
    }
    /// Converts this numeric literal to a fixed-point decimal, if it can be
    /// represented exactly.
    /// -   Parameters:
    ///     - _: A tuple type with fields conforming to ``SignedInteger``
    ///         (and ``FixedWidthInteger``).
    /// -   Returns:
    ///     The value of this numeric literal as an instance of
    ///     [`(units:T, places:T)`](), or nil if the value of either
    ///     field would overflow [`T`]().
    /// >   Note:
    ///     It’s possible for the `places` field to overflow before `units` does.
    ///     For example, this will happen for the literal [`"0.0e-9999999999999999999"`]().
    @inlinable public func `as`<T>(_: (units: T, places: T).Type) -> (units: T, places: T)?
        where T: FixedWidthInteger & SignedInteger {
        guard case .inline(let self) = self else {
            return nil
        }
        return self.as((units: T, places: T).self)
    }
}
extension JSON.Number {
    //  Note: There is currently a compiler crash
    //
    //      https://github.com/apple/swift/issues/63775
    //
    //  that prevents ``parsed(as:)`` from being inlined into clients,
    //  because it uses a lookup table for negative powers of ten.
    //  Therefore, we provide manual specializations for ``Float80``,
    //  ``Double``, and ``Float`` instead. On the bright side, this
    //  means we don’t need to emit a giant conversion function into
    //  the client. (We just have four giant conversion function
    //  specializations in the library.)
    #if (os(Linux) || os(macOS)) && arch(x86_64)
    /// Converts this numeric literal to a ``Float80`` value, or its closest
    /// floating-point representation.
    public func `as`(_: Float80.Type) -> Float80? {
        self.parsed(as: Float80.self)
    }
    #endif
    /// Converts this numeric literal to a ``Double`` value, or its closest
    /// floating-point representation.
    public func `as`(_: Double.Type) -> Double? {
        self.parsed(as: Double.self)
    }
    /// Converts this numeric literal to a ``Float`` value, or its closest
    /// floating-point representation.
    public func `as`(_: Float.Type) -> Float? {
        self.parsed(as: Float.self)
    }

    /// Converts this numeric literal to a ``Float16`` value, or its closest
    /// floating-point representation.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public func `as`(_: Float16.Type) -> Float16? {
        self.parsed(as: Float16.self)
    }
}
extension JSON.Number {
    /// We want floating point types to roundtrip losslessly, the only way to guarantee that is
    /// to render the number as a string and parse it using the standard library parser.
    private func parsed<FloatingPoint>(
        as _: FloatingPoint.Type
    ) -> FloatingPoint? where FloatingPoint: BinaryFloatingPoint & LosslessStringConvertible {
        switch self {
        case .fallback(let string): FloatingPoint.init(string)
        case .infinity(.minus): -FloatingPoint.infinity
        case .infinity(.plus): FloatingPoint.infinity
        case .inline(let inline): FloatingPoint.init("\(inline)")
        case .nan: FloatingPoint.nan
        case .snan: FloatingPoint.signalingNaN
        }
    }
}
