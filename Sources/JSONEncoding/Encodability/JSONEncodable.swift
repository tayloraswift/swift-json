/// A type that can be encoded to a JSON variant value.
public
protocol JSONEncodable
{
    func encoded(as _:JSON.Type) -> JSON
}

extension JSONEncodable where Self:RawRepresentable, RawValue:JSONEncodable
{
    /// Returns the ``encoded(as:)`` witness of this type’s ``RawRepresentable.rawValue``.
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        self.rawValue.encoded(as: JSON.self)
    }
}
extension JSONEncodable where Self:UnsignedInteger
{
    /// Encodes this integer as a value of ``case JSON.number(_:)``.
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .number(.init(self))
    }
}
extension JSONEncodable where Self:SignedInteger
{
    /// Encodes this integer as a value of ``case JSON.number(_:)``.
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .number(.init(self))
    }
}
extension JSONEncodable where Self:Sequence, Element:JSONEncodable
{
    /// Encodes this sequence as a JSON array.
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .array(.init(self.map { $0.encoded(as: JSON.self) }))
    }
}

extension Optional:JSONEncodable where Wrapped:JSONEncodable
{
    /// Encodes this optional as an explicit ``JSON.null``, if
    /// [`nil`]().
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        self?.encoded(as: JSON.self) ?? .null
    }
}
//  We generally do *not* want dictionaries to be encodable, and dictionary
//  literal generate dictionaries by default.
extension [String: Never]:JSONEncodable
{
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .object(.init())
    }
}
extension Array:JSONEncodable where Element:JSONEncodable
{
}
extension Set:JSONEncodable where Element:JSONEncodable
{
}

extension Never:JSONEncodable
{
    /// Never encodes anything.
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        fatalError("unreachable")
    }
}

@available(*, unavailable,
    message: "Encoding floating point values to JSON converts them to decimal form.")
extension Float:JSONEncodable
{
    public
    func encoded(as _:JSON.Type) -> JSON
    {
        fatalError()
    }
}
@available(*, unavailable,
    message: "Encoding floating point values to JSON converts them to decimal form.")
extension Double:JSONEncodable
{
    public
    func encoded(as _:JSON.Type) -> JSON
    {
        fatalError()
    }
}
@available(*, unavailable,
    message: "Encoding floating point values to JSON converts them to decimal form.")
extension Float80:JSONEncodable
{
    public
    func encoded(as _:JSON.Type) -> JSON
    {
        fatalError()
    }
}

extension UInt:JSONEncodable {}
extension UInt64:JSONEncodable {}
extension UInt32:JSONEncodable {}
extension UInt16:JSONEncodable {}
extension UInt8:JSONEncodable {}

extension Int:JSONEncodable {}
extension Int64:JSONEncodable {}
extension Int32:JSONEncodable {}
extension Int16:JSONEncodable {}
extension Int8:JSONEncodable {}

extension Bool:JSONEncodable
{
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .bool(self)
    }
}

extension Unicode.Scalar:JSONEncodable
{
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .string(self.description)
    }
}
extension Character:JSONEncodable
{
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .string(self.description)
    }
}
//  ``Substring`` and ``String`` are ``Sequence``s of ``Character``s,
//  and if we did not provide concrete implementations, they would
//  be caught between default implementations.
extension Substring:JSONEncodable
{
    /// Encodes this substring as a value of ``case JSON.string(_:)``.
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .string(.init(self))
    }
}
extension String:JSONEncodable
{
    /// Encodes this string as a value of ``case JSON.string(_:)``.
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .string(self)
    }
}
extension StaticString:JSONEncodable
{
    /// Encodes this string as a value of ``case JSON.string(_:)``.
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .string(self.description)
    }
}
