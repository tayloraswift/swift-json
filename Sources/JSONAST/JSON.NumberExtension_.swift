extension JSON {
    @frozen public enum NumberExtension_: Sendable {
        case NaN
        case infinity(FloatingPointSign)
    }
}
extension JSON.NumberExtension_: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .NaN: "NaN"
        case .infinity(.plus): "inf"
        case .infinity(.minus): "-inf"
        }
    }
}
