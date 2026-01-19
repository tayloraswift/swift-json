import Grammar
import JSONAST

extension JSON.Node {
    /// Attempts to parse a complete JSON message (either an ``Array`` or an
    /// ``Object``) from raw UTF-8 JSON data.
    public init(parsing json: JSON) throws {
        self = try JSON.RootRule<Int>.parse(json.utf8)
    }
    /// Attempts to parse a complete JSON message (either an ``Array`` or an
    /// ``Object``) from a string.
    public init(parsing string: String) throws {
        self = try JSON.RootRule<String.Index>.parse(string.utf8)
    }
    /// Attempts to parse a complete JSON message (either an ``Array`` or an
    /// ``Object``) from a substring.
    public init(parsing string: Substring) throws {
        self = try JSON.RootRule<String.Index>.parse(string.utf8)
    }

    /// Attempts to parse a a JSON fragment from a string.
    public init(parsingFragment string: String) throws {
        self = try JSON.NodeRule<String.Index>.parse(string.utf8)
    }
    /// Attempts to parse a a JSON fragment from a substring.
    public init(parsingFragment string: Substring) throws {
        self = try JSON.NodeRule<String.Index>.parse(string.utf8)
    }
}
extension JSON.Node: LosslessStringConvertible {
    /// See ``init(parsingFragment:) (String)``.
    public init?(_ description: String) {
        do      { try self.init(parsingFragment: description) } catch   { return nil }
    }
}
