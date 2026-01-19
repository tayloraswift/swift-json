import Grammar

extension JSON {
    /// Matches a numeric literal.
    ///
    /// Numeric literals are always written in decimal.
    ///
    /// The following examples are all valid literals:
    /**
    ```swift
    "5"
    "5.5"
    "-5.5"
    "-55e-2"
    "-55e2"
    "-55e+2"
    ```
    */
    /// Numeric literals may not begin with a prefix `+` sign, although the
    /// exponent field can use a prefix `+`.
    enum NumberRule<Location> {
    }
}
extension JSON.NumberRule: ParsingRule {
    typealias Terminal = UInt8

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws -> JSON.Number
        where   Source.Element == Terminal,
        Source.Index == Location {
        /// ASCII decimal digit terminals.
        typealias DecimalDigit<T> = UnicodeDigit<Location, UInt8, T>.Decimal
            where T: BinaryInteger
        /// ASCII terminals.
        typealias ASCII = UnicodeEncoding<Location, UInt8>

        let start: Source.Index = input.index
        // https://datatracker.ietf.org/doc/html/rfc8259#section-6
        // JSON does not allow prefix '+'
        let sign: FloatingPointSign
        switch input.parse(as: ASCII.Hyphen?.self) {
        case  _?: sign = .minus
        case nil: sign = .plus
        }

        /// parse integral component
        var units: UInt64? = try input.parse(as: DecimalDigit<UInt64>.self)
        while let remainder: UInt64 = input.parse(as: DecimalDigit<UInt64>?.self) {
            guard
            let value: UInt64 = units else {
                continue
            }
            if  case (let shifted, false) = value.multipliedReportingOverflow(by: 10),
                case (let refined, false) = shifted.addingReportingOverflow(remainder) {
                units = refined
            } else {
                units = nil
            }
        }

        /// parse fractional component, if present
        var places: UInt32 = 0
        if  var (_, remainder): (Void, UInt64) = try? input.parse(
                as: (ASCII.Period, DecimalDigit<UInt64>).self
            ) {
            while true {
                places += 1

                if  let value: UInt64 = units {
                    if  case (let shifted, false) = value.multipliedReportingOverflow(by: 10),
                        case (let refined, false) = shifted.addingReportingOverflow(remainder) {
                        units = refined
                    } else {
                        units = nil
                    }
                }

                guard
                let next: UInt64 = input.parse(as: DecimalDigit<UInt64>?.self) else {
                    break
                }

                remainder = next
            }
        }

        let exponent: (sign: FloatingPointSign, magnitude: UInt32)?
        if  let _: Void = input.parse(as: ASCII.E?.self) {
            let sign: FloatingPointSign? = input.parse(as: PlusOrMinus?.self)
            let magnitude: UInt32 = try input.parse(
                as: Pattern.UnsignedInteger<DecimalDigit<UInt32>>.self
            )

            exponent = magnitude > 0 ? (sign: sign ?? .plus, magnitude: magnitude) : nil
        } else {
            exponent = nil
        }

        representable:
        if  let exponent: (sign: FloatingPointSign, magnitude: UInt32),
            var units: UInt64 {
            switch exponent.sign {
            case .minus:
                // note: potential crash if `exponent.magnitude` is absurdly large
                places += exponent.magnitude

            case .plus:
                guard places < exponent.magnitude else {
                    // note: see above
                    places -= exponent.magnitude
                    break
                }

                let shift: Int
                if  units == 0 {
                    places = 0
                    break
                } else {
                    shift = .init(exponent.magnitude - places)
                    places = 0
                }

                if  shift < JSON.Number.Base10.Exp.endIndex,
                    case (let shifted, false) = units.multipliedReportingOverflow(
                        by: JSON.Number.Base10.Exp[shift]
                    ) {
                    units = shifted
                } else {
                    break representable
                }
            }

            return .inline(.init(sign: sign, units: units, places: places))
        } else if
            let units: UInt64 {
            return .inline(.init(sign: sign, units: units, places: places))
        }

        /// number is not representable in efficient format, fall back to string
        let end: Location = input.index
        return .fallback(String.init(decoding: input[start ..< end], as: Unicode.UTF8.self))
    }
}
