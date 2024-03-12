import Grammar

extension JSON
{
    /// Matches a string literal.
    ///
    /// String literals always begin and end with an ASCII double quote character (`"`).
    enum StringRule<Location>
    {
    }
}
extension JSON.StringRule:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> String
        where   Source.Element == Terminal,
                Source.Index == Location
    {
        typealias DoubleQuote = UnicodeEncoding<Location, UInt8>.DoubleQuote

        try input.parse(as: DoubleQuote.self)

        let start:Location      = input.index
        input.parse(as: CodeUnit.self, in: Void.self)
        let end:Location        = input.index
        var string:String       = .init(decoding: input[start ..< end], as: Unicode.UTF8.self)

        while let next:String   = input.parse(as: EscapeSequence?.self)
        {
            string             += next
            let start:Location  = input.index
            input.parse(as: CodeUnit.self, in: Void.self)
            let end:Location    = input.index
            string             += .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
        }

        try input.parse(as: DoubleQuote.self)
        return string
    }
}
