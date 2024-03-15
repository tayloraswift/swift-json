extension Character:JSONStringDecodable
{
    /// Witnesses `Character`’s ``JSONStringDecodable`` conformance,
    /// throwing a ``JSON.ValueError`` instead of trapping on multi-character
    /// input.
    ///
    /// This is needed because its ``LosslessStringConvertible.init(_:)``
    /// witness traps on invalid input instead of returning [`nil`](), which
    /// causes its default implementation (where [`Self:LosslessStringConvertible`]())
    /// to do the same.
    @inlinable public
    init(json:JSON.Node) throws
    {
        let string:String = try .init(json: json)
        if  string.startIndex < string.endIndex,
            string.index(after: string.startIndex) == string.endIndex
        {
            self = string[string.startIndex]
        }
        else
        {
            throw JSON.ValueError<String, Self>.init(invalid: string)
        }
    }
}
