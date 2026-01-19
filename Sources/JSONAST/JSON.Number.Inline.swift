extension JSON.Number {
    /// This type is memory-efficient, and can store fixed-point numbers with
    /// up to 64 bits of precision. It uses all 64 bits to encode its magnitude,
    /// which enables it to round-trip integers of width up to ``UInt64``.
    @frozen public struct Inline: Hashable, Equatable, Sendable {
        // this layout should allow instances of `Number` to fit in 2 words.
        // this is backed by an `Int`, but the swift compiler can optimize it
        // into a `UInt8`-sized field

        /// The sign of this numeric literal.
        public var sign: FloatingPointSign
        // cannot have an inlinable property wrapper
        @usableFromInline internal var _places: UInt32
        /// The number of decimal places this numeric literal has.
        ///
        /// >   Note:
        /// >   This property has type ``UInt64`` to facilitate computations with
        ///     ``units``. It is backed by a ``UInt32`` and can therefore only store
        ///     32 bits of precision.
        @inlinable public var places: UInt64 {
            .init(self._places)
        }
        /// The magnitude of this numeric literal, expressed in units of ``places``.
        ///
        /// If ``units`` is [`123`](), and ``places`` is [`2`](), that would represent
        /// a magnitude of [`1.23`]().
        public var units: UInt64
        /// Creates a numeric literal.
        /// -   Parameters:
        ///     - sign: The sign, positive or negative.
        ///     - units: The magnitude, in units of `places`.
        ///     - places: The number of decimal places.
        @inlinable public init(sign: FloatingPointSign, units: UInt64, places: UInt32 = 0) {
            self.sign       = sign
            self.units      = units
            self._places    = places
        }
    }
}
extension JSON.Number.Inline {
    @inlinable public init<T>(_ signed: T) where T: SignedInteger {
        self.init(sign: signed < 0 ? .minus : .plus, units: UInt64.init(signed.magnitude))
    }
    @inlinable public init<T>(_ unsigned: T) where T: UnsignedInteger {
        self.init(sign: .plus, units: UInt64.init(unsigned))
    }
}
extension JSON.Number.Inline {
    @inlinable public func `as`<T>(
        _: T.Type
    ) -> T? where T: FixedWidthInteger & UnsignedInteger {
        guard self.places == 0 else {
            return nil
        }
        switch self.sign {
        case .minus:
            return self.units == 0 ? 0 : nil
        case .plus:
            return T.init(exactly: self.units)
        }
    }

    @inlinable public func `as`<T>(
        _: T.Type
    ) -> T? where T: FixedWidthInteger & SignedInteger {
        guard self.places == 0 else {
            return nil
        }
        switch self.sign {
        case .minus:
            let negated: Int64 = .init(bitPattern: 0 &- self.units)
            return negated <= 0 ? T.init(exactly: negated) : nil
        case .plus:
            return T.init(exactly: self.units)
        }
    }

    @inlinable public func `as`<T>(_: (units: T, places: T).Type) -> (units: T, places: T)?
        where T: FixedWidthInteger & SignedInteger {
        guard let places: T = T.init(exactly: self.places) else {
            return nil
        }
        switch self.sign {
        case .minus:
            let negated: Int64 = Int64.init(bitPattern: 0 &- self.units)
            guard negated      <= 0,
            let units: T = T.init(exactly: negated) else {
                return nil
            }
            return (units: units, places: places)
        case .plus:
            guard let units: T = T.init(exactly: self.units) else {
                return nil
            }
            return (units: units, places: places)
        }
    }
}
extension JSON.Number.Inline: CustomStringConvertible {
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
    public var description: String {
        guard self.places > 0 else {
            switch self.sign {
            case .plus: return  "\(self.units)"
            case .minus: return "-\(self.units)"
            }
        }
        let places: Int      = .init(self.places)
        let unpadded: String = .init(self.units)
        let string: String   = """
        \(String.init(repeating: "0", count: Swift.max(0, 1 + places - unpadded.count)))\
        \(unpadded)
        """
        switch self.sign {
        case .plus: return  "\(string.dropLast(places)).\(string.suffix(places))"
        case .minus: return "-\(string.dropLast(places)).\(string.suffix(places))"
        }
    }
}
