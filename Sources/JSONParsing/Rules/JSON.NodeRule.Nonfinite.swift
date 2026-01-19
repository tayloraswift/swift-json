import Grammar

extension JSON.NodeRule {
    enum Nonfinite: ParsingRule {
        typealias Terminal = UInt8

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws -> JSON.Number
            where Source.Element == Terminal, Source.Index == Location {

            if  let _: Void = input.parse(
                    as: UnicodeEncoding<Location, UInt8>.LowercaseS?.self
                ) {
                try input.parse(as: JSON.NodeRule<Location>.NaN.self)
                return .snan
            } else if
                let _: Void = input.parse(as: JSON.NodeRule<Location>.NaN?.self) {
                return .nan
            }

            let sign: FloatingPointSign
            if  let _: Void = input.parse(as: UnicodeEncoding<Location, UInt8>.Hyphen?.self) {
                sign = .minus
            } else {
                sign = .plus
            }

            try input.parse(as: Inf.self)
            return .infinity(sign)
        }
    }
}
