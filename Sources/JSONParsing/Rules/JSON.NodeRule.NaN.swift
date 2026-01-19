import Grammar

extension JSON.NodeRule {
    /// A literal `NaN` expression.
    enum NaN: LiteralRule {
        typealias Terminal = UInt8

        /// The ASCII string `NaN`.
        static var literal: [UInt8] { [0x4e, 0x61, 0x4e] }
    }
}
