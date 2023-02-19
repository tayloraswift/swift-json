extension JSON.Array
{
    @inlinable public
    init(elements:some Sequence<some JSONEncodable>)
    {
        self.init(elements.map { $0.encoded(as: JSON.self) })
    }
    @inlinable public mutating
    func append(_ element:some JSONEncodable)
    {
        self.elements.append(element.encoded(as: JSON.self))
    }
    @inlinable public mutating
    func append(_ populate:(inout JSON.Object) throws -> ()) rethrows
    {
        self.append(try JSON.Object.init(with: populate))
    }
    @inlinable public mutating
    func append(_ populate:(inout Self) throws -> ()) rethrows
    {
        self.append(try Self.init(with: populate))
    }
}
extension JSON.Array
{
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
}
extension JSON.Array:JSONEncodable
{
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .array(self)
    }
}
