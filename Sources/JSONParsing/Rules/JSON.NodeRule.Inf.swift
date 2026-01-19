import Grammar

extension JSON.NodeRule {
    enum Inf: LiteralRule {
        typealias Terminal = UInt8
        // "inf"
        static var literal: [UInt8] { [0x69, 0x6e, 0x66] }
    }
}
