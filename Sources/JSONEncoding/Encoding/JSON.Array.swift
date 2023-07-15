extension JSON.Array
{
    @inlinable public
    init(encoding elements:some Sequence<some JSONEncodable>)
    {
        self.init(elements.map { $0.encoded(as: JSON.self) })
    }
}
extension JSON.Array
{
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
    }
}
extension JSON.Array
{
    @inlinable public mutating
    func append(_ element:some JSONEncodable)
    {
        self.elements.append(element.encoded(as: JSON.self))
    }
    /// Encodes and appends the given value if it is non-`nil`, does
    /// nothing otherwise.
    @inlinable public mutating
    func push(_ element:(some JSONEncodable)?)
    {
        element.map
        {
            self.append($0)
        }
    }
    @available(*, deprecated, message: "use append(_:) for non-optional values")
    public mutating
    func push(_ element:some JSONEncodable)
    {
        self.append(element)
    }
}
extension JSON.Array
{
    @inlinable public mutating
    func append(with encode:(inout JSON.Array) -> ())
    {
        self.append(JSON.Array.init(with: encode))
    }
    @inlinable public mutating
    func append(with encode:(inout JSON.ObjectEncoder<JSON.Key>) -> ())
    {
        self.append(JSON.Object.init(with: encode))
    }
    @inlinable public mutating
    func append<CodingKey>(using _:CodingKey.Type = CodingKey.self,
        with encode:(inout JSON.ObjectEncoder<CodingKey>) -> ())
    {
        self.append(JSON.Object.init(with: encode))
    }
}

extension JSON.Array:JSONEncodable
{
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .array(self)
    }
}
