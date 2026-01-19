import Grammar

extension JSON.NodeRule {
    /// A literal `nan` expression, all lowercase.
    enum NaN: LiteralRule {
        typealias Terminal = UInt8

        /// The ASCII string `nan`.
        static var literal: [UInt8] { [0x6e, 0x61, 0x6e] }
    }
}
