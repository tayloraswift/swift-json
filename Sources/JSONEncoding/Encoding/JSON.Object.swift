extension JSON.Object
{
    @inlinable public
    init(encoding fields:some Sequence<(key:String, value:some JSONEncodable)>)
    {
        self.init(fields.map { (.init(rawValue: $0.key), $0.value.encoded(as: JSON.self)) })
    }
}
extension JSON.Object
{
    @inlinable internal
    subscript<NestedKey>(using _:NestedKey.Type) -> JSON.ObjectEncoder<NestedKey>
    {
        get
        {
            .init(fields: self.fields)
        }
        _modify
        {
            var encoder:JSON.ObjectEncoder<NestedKey> = self[using: NestedKey.self]
            self.fields = []
            defer { self.fields = encoder.fields }
            yield &encoder
        }
    }

    @inlinable public
    init(encoding encodable:__shared some JSONObjectEncodable)
    {
        self.init(with: encodable.encode(to:))
    }
    @inlinable public
    init(with populate:(inout JSON.ObjectEncoder<JSON.Key>) throws -> ()) rethrows
    {
        self.init()
        try populate(&self[using: JSON.Key.self])
    }
    @inlinable public
    init<CodingKey>(_:CodingKey.Type = CodingKey.self,
        with populate:(inout JSON.ObjectEncoder<CodingKey>) throws -> ()) rethrows
    {
        self.init()
        try populate(&self[using: CodingKey.self])
    }
}
extension JSON.Object:JSONBuilder
{
    @inlinable public mutating
    func append(_ key:String, _ value:some JSONEncodable)
    {
        self.fields.append((.init(rawValue: key), value.encoded(as: JSON.self)))
    }
}
extension JSON.Object
{
    @inlinable public mutating
    func append(_ key:some RawRepresentable<String>, _ value:some JSONEncodable)
    {
        self.append(key.rawValue, value)
    }
    @inlinable public mutating
    func push(_ key:some RawRepresentable<String>, _ value:(some JSONEncodable)?)
    {
        value.map
        {
            self.append(key, $0)
        }
    }
    @available(*, deprecated, message: "use append(_:_:) for non-optional values")
    public mutating
    func push(_ key:some RawRepresentable<String>, _ value:some JSONEncodable)
    {
        self.append(key, value)
    }
}
extension JSON.Object
{
    @inlinable public
    subscript(key:some RawRepresentable<String>,
        with encode:(inout JSON.Array) -> ()) -> Void
    {
        mutating get
        {
            self[key.rawValue, with: encode]
        }
    }
    @inlinable public
    subscript(key:some RawRepresentable<String>,
        with encode:(inout JSON.ObjectEncoder<JSON.Key>) -> ()) -> Void
    {
        mutating get
        {
            self[key.rawValue, with: encode]
        }
    }
    @inlinable public
    subscript<NestedKey>(key:some RawRepresentable<String>,
        using _:NestedKey.Type = NestedKey.self,
        with encode:(inout JSON.ObjectEncoder<NestedKey>) -> ()) -> Void
    {
        mutating get
        {
            self[key.rawValue, with: encode]
        }
    }
}
extension JSON.Object:JSONEncodable
{
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .object(self)
    }
}
