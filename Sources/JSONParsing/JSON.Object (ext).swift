import Grammar
import JSONAST

extension JSON.Object
{
    /// Attempts to parse a JSON object from raw UTF-8 JSON data.
    ///
    /// >   Note:
    ///    Unlike BSON lists, you cannot reparse JSON arrays as objects.
    public
    init(parsing json:JSON) throws
    {
        self.init(try JSON.NodeRule<Int>.Object.parse(json.utf8))
    }
    /// Attempts to parse a JSON object from a string.
    ///
    /// >   Note:
    ///     Unlike BSON lists, you cannot reparse JSON arrays as objects.
    public
    init(parsing string:String) throws
    {
        self.init(try JSON.NodeRule<String.Index>.Object.parse(string.utf8))
    }
    /// Attempts to parse a JSON object from a substring.
    ///
    /// >   Note:
    ///    Unlike BSON lists, you cannot reparse JSON arrays as objects.
    public
    init(parsing string:Substring) throws
    {
        self.init(try JSON.NodeRule<String.Index>.Object.parse(string.utf8))
    }
}
extension JSON.Object:LosslessStringConvertible
{
    /// See ``init(parsing:)``.
    public
    init?(_ description:String)
    {
        do      { try self.init(parsing: description) }
        catch   { return nil }
    }
}
