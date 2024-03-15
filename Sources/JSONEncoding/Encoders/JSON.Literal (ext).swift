import JSONAST

extension JSON.Literal<Never?>
{
    /// Encodes `null` to the provided JSON stream.
    @inlinable internal static
    func += (json:inout JSON, self:Self)
    {
        json.utf8 += "null".utf8
    }
}
extension JSON.Literal<Bool>
{
    /// Encodes `true` or `false` to the provided JSON stream.
    @inlinable internal static
    func += (json:inout JSON, self:Self)
    {
        json.utf8 += (self.value ? "true" : "false").utf8
    }
}
extension JSON.Literal where Value:BinaryInteger
{
    /// Encodes this literal’s integer ``value`` to the provided JSON stream. The value’s
    /// ``CustomStringConvertible description`` witness must format the value in base-10.
    @inlinable internal static
    func += (json:inout JSON, self:Self)
    {
        json.utf8 += self.value.description.utf8
    }
}
