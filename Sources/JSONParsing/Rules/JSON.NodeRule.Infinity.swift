import Grammar

extension JSON.NodeRule {
    /// Matches `inf` or `-inf`.
    enum Infinity: ParsingRule {
        typealias Terminal = UInt8

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws -> FloatingPointSign
            where Source.Element == Terminal, Source.Index == Location {

            let sign: FloatingPointSign
            if  let _: Void = input.parse(as: UnicodeEncoding<Location, UInt8>.Hyphen?.self) {
                sign = .minus
            } else {
                sign = .plus
            }

            try input.parse(as: Inf.self)
            return sign
        }
    }
}
