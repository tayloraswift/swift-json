import Grammar

extension JSON.NodeRule
{
    /// A literal `false` expression.
    enum False:LiteralRule
    {
        typealias Terminal = UInt8

        /// The ASCII string `false`.
        static
        var literal:[UInt8] { [0x66, 0x61, 0x6c, 0x73, 0x65] }
    }
}
