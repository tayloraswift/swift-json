import JSONAST

/// A type that can be encoded to a JSON string. This protocol
/// exists to allow types that also conform to ``LosslessStringConvertible``
/// to opt-in to automatic ``JSONEncodable`` conformance as well.
public
protocol JSONStringEncodable:JSONEncodable
{
    /// Converts an instance of this type to a string. This requirement
    /// restates its counterpart in ``CustomStringConvertible`` if
    /// [`Self`]() also conforms to it.
    var description:String { get }
}
extension JSONStringEncodable
{
    /// Encodes the ``description`` of this instance as a JSON string.
    ///
    /// This default implementation is provided on an extension on a
    /// dedicated protocol rather than an extension on ``JSONEncodable``
    /// itself to prevent unexpected behavior for types (such as ``Int``)
    /// who implement ``LosslessStringConvertible``, but expect to be
    /// encoded as something besides a string.
    @inlinable public
    func encode(to json:inout JSON)
    {
        json += JSON.Literal<String>.init(self.description)
    }
}
