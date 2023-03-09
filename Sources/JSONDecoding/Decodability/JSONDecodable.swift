/// A type that can be decoded from a JSON variant value.
public
protocol JSONDecodable
{
    /// Attempts to cast a JSON variant backed by some storage type to an
    /// instance of this type. The implementation can copy the contents
    /// of the backing storage if needed.
    init(json:JSON) throws
}

extension Never:JSONDecodable
{
    /// Always throws a ``JSON.TypecastError``.
    @inlinable public
    init(json:JSON) throws
    {
        throw JSON.TypecastError<Never>.init(invalid: json)
    }
}
extension Bool:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        self = try json.cast { $0.as(Self.self) }
    }
}

extension UInt8:JSONDecodable {}
extension UInt16:JSONDecodable {}
extension UInt32:JSONDecodable {}
extension UInt64:JSONDecodable {}
extension UInt:JSONDecodable {}

extension Int8:JSONDecodable {}
extension Int16:JSONDecodable {}
extension Int32:JSONDecodable {}
extension Int64:JSONDecodable {}
extension Int:JSONDecodable {}

extension Float:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        self = try json.cast { $0.as(Self.self) }
    }
}
extension Double:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        self = try json.cast { $0.as(Self.self) }
    }
}
#if (os(Linux) || os(macOS)) && arch(x86_64)
extension Float80:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        self = try json.cast { $0.as(Self.self) }
    }
}
#endif
extension JSONDecodable where Self:SignedInteger & FixedWidthInteger
{
    @inlinable public
    init(json:JSON) throws
    {
        self = try json.cast { try $0.as(Self.self) }
    }
}
extension JSONDecodable where Self:UnsignedInteger & FixedWidthInteger
{
    @inlinable public
    init(json:JSON) throws
    {
        self = try json.cast { try $0.as(Self.self) }
    }
}
extension JSONDecodable where Self:RawRepresentable, RawValue:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
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

extension Optional:JSONDecodable where Wrapped:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        if case .null = json 
        {
            self = .none 
        }
        else
        {
            self = .some(try .init(json: json))
        }
    }
}
extension Dictionary:JSONDecodable where Key == String, Value:JSONDecodable
{
    /// Decodes an unordered dictionary from the given document. Dictionaries
    /// are not ``JSONEncodable``, because round-tripping them loses the field
    /// ordering information.
    @inlinable public
    init(json:JSON) throws
    {
        let object:JSON.Object = try .init(json: json)

        self.init(minimumCapacity: object.count)
        for field:JSON.ExplicitField<String> in object
        {
            if case _? = self.updateValue(try field.decode(to: Value.self), forKey: field.key)
            {
                throw JSON.ObjectKeyError<String>.duplicate(field.key)
            }
        }
    }
}
extension Array:JSONDecodable where Element:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        let array:JSON.Array = try .init(json: json)
        self = try array.map { try $0.decode(to: Element.self) }
    }
}
extension Set:JSONDecodable where Element:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        let array:JSON.Array = try .init(json: json)

        self.init()
        self.reserveCapacity(array.count)
        for field:JSON.ExplicitField<Int> in array
        {
            self.update(with: try field.decode(to: Element.self))
        }
    }
}
