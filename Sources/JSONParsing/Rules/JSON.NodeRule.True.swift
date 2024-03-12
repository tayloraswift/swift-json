import Grammar

extension JSON.NodeRule
{
    /// A literal `true` expression.
    enum True:LiteralRule
    {
        typealias Terminal = UInt8

        /// The ASCII string `true`.
        static
        var literal:[UInt8] { [0x74, 0x72, 0x75, 0x65] }
    }
}

