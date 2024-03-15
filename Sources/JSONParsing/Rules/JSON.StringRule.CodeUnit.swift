import Grammar

extension JSON.StringRule
{
    /// Matches a UTF-8 code unit that is allowed to appear inline in a string literal.
    enum CodeUnit:TerminalRule
    {
        typealias Terminal = UInt8
        typealias Construction = Void

        static
        func parse(terminal:UInt8) -> Void?
        {
            switch terminal
            {
            case 0x20 ... 0x21, 0x23 ... 0x5b, 0x5d ... 0xff:   ()
            default:                                            nil
            }
        }
    }
}
