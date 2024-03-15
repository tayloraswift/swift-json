import Grammar

extension JSON
{
    /// Matches any value, including fragment values.
    ///
    /// Only use this if you are doing manual JSON parsing. Most web services
    /// should send complete ``JSON.RootRule`` messages through their public APIs.
    enum NodeRule<Location>
    {
    }
}
extension JSON.NodeRule:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> JSON.Node
        where   Source.Element == Terminal,
                Source.Index == Location
    {
        if  let number:JSON.Number = input.parse(as: JSON.NumberRule<Location>?.self)
        {
            return .number(number)
        }
        else if
            let string:String = input.parse(as: JSON.StringRule<Location>?.self)
        {
            return .string(JSON.Literal<String>.init(string))
        }
        else if
            let items:[(JSON.Key, JSON.Node)] = input.parse(as: Object?.self)
        {
            return .object(.init(items))
        }
        else if
            let elements:[JSON.Node] = input.parse(as: Array?.self)
        {
            return .array(.init(elements))
        }
        else if
            let _:Void = input.parse(as: True?.self)
        {
            return .bool(true)
        }
        else if
            let _:Void = input.parse(as: False?.self)
        {
            return .bool(false)
        }
        else
        {
            try input.parse(as: Null.self)
            return .null
        }
    }
}
