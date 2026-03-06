import Grammar
import JSONAST

extension JSON.Object {
    /// Attempts to parse a JSON object from raw UTF-8 JSON data.
    ///
    /// >   Note:
    ///    Unlike BSON lists, you cannot reparse JSON arrays as objects.
    public init(parsing json: JSON) throws {
        self.init(try JSON.NodeRule<Int>.Object.parse(json.utf8))
    }
    /// Attempts to parse a JSON object from a span.
    public init(parsing span: Span<UInt8>) throws {
        self.init(
            try span.withUnsafeBufferPointer { buffer in
                try JSON.NodeRule<Int>.Object.parse(buffer)
            }
        )
    }
    /// Attempts to parse a JSON object from a raw span.
    public init(parsing span: RawSpan) throws {
        self.init(
            try span.withUnsafeBytes { buffer in
                try JSON.NodeRule<Int>.Object.parse(buffer)
            }
        )
    }
    /// Attempts to parse a JSON object from a string.
    ///
    /// >   Note:
    ///     Unlike BSON lists, you cannot reparse JSON arrays as objects.
    public init(parsing string: String) throws {
        self.init(try JSON.NodeRule<String.Index>.Object.parse(string.utf8))
    }
    /// Attempts to parse a JSON object from a substring.
    ///
    /// >   Note:
    ///    Unlike BSON lists, you cannot reparse JSON arrays as objects.
    public init(parsing string: Substring) throws {
        self.init(try JSON.NodeRule<String.Index>.Object.parse(string.utf8))
    }
}
extension JSON.Object: LosslessStringConvertible {
    /// See ``init(parsing:) (String)``.
    public init?(_ description: String) {
        do      { try self.init(parsing: description) } catch   { return nil }
    }
}
