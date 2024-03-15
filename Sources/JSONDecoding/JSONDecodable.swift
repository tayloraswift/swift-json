/// A type that can be decoded from a JSON variant value.
public
protocol JSONDecodable
{
    /// Attempts to cast a JSON variant backed by some storage type to an
    /// instance of this type. The implementation can copy the contents
    /// of the backing storage if needed.
    init(json:JSON.Node) throws
}
extension JSONDecodable where Self:SignedInteger & FixedWidthInteger
{
    @inlinable public
    init(json:JSON.Node) throws
    {
        self = try json.cast { try $0.as(Self.self) }
    }
}
extension JSONDecodable where Self:UnsignedInteger & FixedWidthInteger
{
    @inlinable public
    init(json:JSON.Node) throws
    {
        self = try json.cast { try $0.as(Self.self) }
    }
}
extension JSONDecodable where Self:RawRepresentable, RawValue:JSONDecodable & Sendable
{
    @inlinable public
    init(json:JSON.Node) throws
    {
        let rawValue:RawValue = try .init(json: json)
        if  let value:Self = .init(rawValue: rawValue)
        {
            self = value
        }
        else
        {
            throw JSON.ValueError<RawValue, Self>.init(invalid: rawValue)
        }
    }
}
