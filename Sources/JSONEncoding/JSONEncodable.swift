import JSONAST

public
protocol JSONEncodable
{
    func encode(to json:inout JSON)
}
extension JSONEncodable where Self:StringProtocol
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
        json += JSON.Literal<Self>.init(self)
    }
}
extension JSONEncodable where Self:BinaryInteger
{
    @inlinable public
    func encode(to json:inout JSON)
    {
        json += JSON.Literal<Self>.init(self)
    }
}
extension JSONEncodable where Self:RawRepresentable, RawValue:JSONEncodable
{
    @inlinable public
    func encode(to json:inout JSON)
    {
        self.rawValue.encode(to: &json)
    }
}
