import Grammar

extension JSON.NodeRule.Object
{
    /// Matches an key-value expression.
    ///
    /// A key-value expression consists of a ``JSON.StringRule``, a ``JSON.ColonRule``, and
    /// a recursive instance of ``JSON.NodeRule``.
    enum Item
    {
    }
}
extension JSON.NodeRule.Object.Item:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws ->
        (
            key:JSON.Key,
            value:JSON.Node
        )
        where Source.Index == Location, Source.Element == Terminal
    {
        let key:String  = try input.parse(as: JSON.StringRule<Location>.self)
        try input.parse(as: JSON.ColonRule<Location>.self)
        let value:JSON.Node  = try input.parse(as: JSON.NodeRule<Location>.self)
        return (.init(rawValue: key), value)
    }
}
