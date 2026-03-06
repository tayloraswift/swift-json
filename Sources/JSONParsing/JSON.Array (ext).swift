import Grammar
import JSONAST

extension JSON.Array {
    /// Attempts to parse a JSON array from raw UTF-8 JSON data.
    public init(parsing json: JSON) throws {
        self.init(try JSON.NodeRule<Int>.Array.parse(json.utf8))
    }
    /// Attempts to parse a JSON array from a span
    public init(parsing span: Span<UInt8>) throws {
        self.init(
            try span.withUnsafeBufferPointer { buffer in
                try JSON.NodeRule<Int>.Array.parse(buffer)
            }
        )
    }
    /// Attempts to parse a JSON array from a raw span
    public init(parsing span: RawSpan) throws {
        self.init(
            try span.withUnsafeBytes { buffer in
                try JSON.NodeRule<Int>.Array.parse(buffer)
            }
        )
    }
    /// Attempts to parse a JSON array from a string.
    public init(parsing string: String) throws {
        self.init(try JSON.NodeRule<String.Index>.Array.parse(string.utf8))
    }
    /// Attempts to parse a JSON array from a substring.
    public init(parsing string: Substring) throws {
        self.init(try JSON.NodeRule<String.Index>.Array.parse(string.utf8))
    }
}
extension JSON.Array: LosslessStringConvertible {
    /// See ``init(parsing:) (String)``.
    public init?(_ description: String) {
        do { try self.init(parsing: description) } catch { return nil }
    }
}
