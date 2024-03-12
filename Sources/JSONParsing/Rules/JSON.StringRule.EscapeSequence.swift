import Grammar

extension JSON.StringRule
{
    /// Matches a sequence of escaped UTF-16 code units.
    ///
    /// A UTF-16 escape sequence consists of `\u`, followed by four hexadecimal digits.
    enum EscapeSequence
    {
    }
}
extension JSON.StringRule.EscapeSequence:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> String
        where   Source.Element == Terminal,
                Source.Index == Location
    {
        typealias HexDigit = UnicodeDigit<Location, UInt8, UInt16>.Hex
        typealias ASCII = UnicodeEncoding<Location, UInt8>

        try input.parse(as: ASCII.Backslash.self)
        var unescaped:String = ""
        while true
        {
            if  let scalar:Unicode.Scalar = input.parse(
                        as: JSON.StringRule<Location>.EscapedCodeUnit?.self)
            {
                unescaped.append(Character.init(scalar))
            }
            else
            {
                try input.parse(as: ASCII.LowercaseU.self)
                let value:UInt16 =
                    (try input.parse(as: HexDigit.self) << 12) |
                    (try input.parse(as: HexDigit.self) <<  8) |
                    (try input.parse(as: HexDigit.self) <<  4) |
                    (try input.parse(as: HexDigit.self))
                if let scalar:Unicode.Scalar = Unicode.Scalar.init(value)
                {
                    unescaped.append(Character.init(scalar))
                }
                else
                {
                    throw JSON.InvalidUnicodeScalarError.init(value: value)
                }
            }

            guard case _? = input.parse(as: ASCII.Backslash?.self)
            else
            {
                break
            }
        }
        return unescaped
    }
}
