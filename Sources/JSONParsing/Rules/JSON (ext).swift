import Grammar

extension JSON
{
    typealias CommaRule<Location> =
        Pattern.Pad<UnicodeEncoding<Location, UInt8>.Comma, WhitespaceRule<Location>>

    typealias BracketLeftRule<Location> =
        Pattern.Pad<UnicodeEncoding<Location, UInt8>.BracketLeft, WhitespaceRule<Location>>

    typealias BracketRightRule<Location> =
        Pattern.Pad<UnicodeEncoding<Location, UInt8>.BracketRight, WhitespaceRule<Location>>

    typealias BraceLeftRule<Location> =
        Pattern.Pad<UnicodeEncoding<Location, UInt8>.BraceLeft, WhitespaceRule<Location>>

    typealias ColonRule<Location> =
        Pattern.Pad<UnicodeEncoding<Location, UInt8>.Colon, WhitespaceRule<Location>>

    typealias BraceRightRule<Location> =
        Pattern.Pad<UnicodeEncoding<Location, UInt8>.BraceRight, WhitespaceRule<Location>>
}
