import Grammar

extension JSON
{
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
    enum NumberRule<Location>
    {
    }
}
extension JSON.NumberRule:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> JSON.Number
        where   Source.Element == Terminal,
                Source.Index == Location
    {
        /// ASCII decimal digit terminals.
        typealias DecimalDigit<T> = UnicodeDigit<Location, UInt8, T>.Decimal
            where T:BinaryInteger
        /// ASCII terminals.
        typealias ASCII = UnicodeEncoding<Location, UInt8>

        // https://datatracker.ietf.org/doc/html/rfc8259#section-6
        // JSON does not allow prefix '+'
        let sign:FloatingPointSign
        switch input.parse(as: ASCII.Hyphen?.self)
        {
        case  _?:   sign = .minus
        case nil:   sign = .plus
        }

        var units:UInt64    =
            try  input.parse(as: Pattern.UnsignedInteger<DecimalDigit<UInt64>>.self)
        var places:UInt32   = 0
        if  var (_, remainder):(Void, UInt64) =
            try? input.parse(as: (ASCII.Period, DecimalDigit<UInt64>).self)
        {
            while true
            {
                if  case (let shifted, false) = units.multipliedReportingOverflow(by: 10),
                    case (let refined, false) = shifted.addingReportingOverflow(remainder)
                {
                    places += 1
                    units = refined
                }
                else
                {
                    throw Pattern.IntegerOverflowError<UInt64>.init()
                }

                if let next:UInt64 = input.parse(as: DecimalDigit<UInt64>?.self)
                {
                    remainder = next
                }
                else
                {
                    break
                }
            }
        }
        if  let _:Void = input.parse(as: ASCII.E?.self)
        {
            let sign:FloatingPointSign? = input.parse(as: PlusOrMinus?.self)
            let exponent:UInt32 = try input.parse(
                as: Pattern.UnsignedInteger<DecimalDigit<UInt32>>.self)
            // you too, can exploit the vulnerabilities below
            switch sign
            {
            case .minus?:
                places += exponent

            case .plus?, nil:
                guard places < exponent
                else
                {
                    places -= exponent
                    break
                }
                defer
                {
                    places = 0
                }
                guard units != 0
                else
                {
                    break
                }
                let shift:Int = .init(exponent - places)
                if  shift < JSON.Number.Base10.Exp.endIndex,
                    case (let shifted, false) = units.multipliedReportingOverflow(
                        by: JSON.Number.Base10.Exp[shift])
                {
                    units = shifted
                }
                else
                {
                    throw Pattern.IntegerOverflowError<UInt64>.init()
                }
            }
        }
        return .init(sign: sign, units: units, places: places)
    }
}
