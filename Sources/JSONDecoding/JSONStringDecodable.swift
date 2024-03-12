/// A type that can be decoded from a JSON UTF-8 string. This protocol
/// exists to allow types that also conform to ``LosslessStringConvertible``
/// to opt-in to automatic ``JSONDecodable`` conformance as well.
public
protocol JSONStringDecodable:JSONDecodable
{
    /// Converts a string to an instance of this type. This requirement
    /// restates its counterpart in ``LosslessStringConvertible`` if
    /// [`Self`]() also conforms to it.
    init?(_ description:String)
}
extension JSONStringDecodable
{
    /// Attempts to cast the given variant value to a string, and then
    /// delegates to this type’s ``init(_:)`` witness.
    ///
    /// This default implementation is provided on an extension on a
    /// dedicated protocol rather than an extension on ``JSONDecodable``
    /// itself to prevent unexpected behavior for types (such as ``Int``)
    /// who implement ``LosslessStringConvertible``, but expect to be
    /// decoded from a variant value that is not a string.
    @inlinable public
    init(json:JSON.Node) throws
    {
        let string:String = try .init(json: json)
        if  let value:Self = .init(string)
        {
            self = value
        }
        else
        {
            throw JSON.ValueError<String, Self>.init(invalid: string)
        }
    }
}
