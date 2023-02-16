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

extension Float:JSONDecodable {}
extension Double:JSONDecodable {}
extension Float80:JSONDecodable {}

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
extension JSONDecodable where Self:BinaryFloatingPoint
{
    @inlinable public
    init(json:JSON) throws
    {
        self = try json.cast { $0.as(Self.self) }
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

extension JSON.Array:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        self.init(try json.cast { $0.array })
    }
}

extension JSON.Dictionary:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        try self.init(object: try json.cast { $0.object })
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
