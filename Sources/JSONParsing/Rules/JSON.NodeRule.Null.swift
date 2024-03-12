import Grammar

extension JSON.NodeRule
{
    /// A literal `null` expression.
    enum Null:LiteralRule
    {
        typealias Terminal = UInt8

        /// The ASCII string `null`.
        static
        var literal:[UInt8] { [0x6e, 0x75, 0x6c, 0x6c] }
    }
}
