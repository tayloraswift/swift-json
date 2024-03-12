import Grammar

extension JSON.NodeRule
{
    /// Matches an array literal.
    ///
    /// Array literals begin and end with square brackets (`[` and `]`), and
    /// recursively contain instances of ``JSON.NodeRule`` separated by ``JSON.CommaRule``s.
    /// Trailing commas (a JSON5 extension) are not allowed.
    enum Array
    {
    }
}
extension JSON.NodeRule.Array:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> [JSON.Node]
        where   Source.Element == Terminal,
                Source.Index == Location
    {
        try input.parse(as: JSON.BracketLeftRule<Location>.self)
        var elements:[JSON.Node]
        if let head:JSON.Node = try? input.parse(as: JSON.NodeRule<Location>.self)
        {
            elements = [head]
            while   let (_, next):(Void, JSON.Node) = try? input.parse(
                        as: (JSON.CommaRule<Location>, JSON.NodeRule<Location>).self)
            {
                elements.append(next)
            }
        }
        else
        {
            elements = []
        }
        try input.parse(as: JSON.BracketRightRule<Location>.self)
        return elements
    }
}
