import Grammar

extension JSON.NodeRule
{
    /// Matches an object literal.
    ///
    /// Object literals begin and end with curly braces (`{` and `}`), and
    /// contain instances of ``Item`` separated by ``JSON.CommaRule``s.
    /// Trailing commas are not allowed.
    enum Object
    {
    }
}
extension JSON.NodeRule.Object:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(_ input:inout ParsingInput<some ParsingDiagnostics<Source>>)
        throws -> [(key:JSON.Key, value:JSON.Node)]
        where Source.Index == Location, Source.Element == Terminal
    {
        try input.parse(as: JSON.BraceLeftRule<Location>.self)
        var items:[(key:JSON.Key, value:JSON.Node)]
        if let head:(key:JSON.Key, value:JSON.Node) = try? input.parse(as: Item.self)
        {
            items = [head]
            while   let (_, next):(Void, (key:JSON.Key, value:JSON.Node)) = try? input.parse(
                        as: (JSON.CommaRule<Location>, Item).self)
            {
                items.append(next)
            }
        }
        else
        {
            items = []
        }
        try input.parse(as: JSON.BraceRightRule<Location>.self)
        return items
    }
}
