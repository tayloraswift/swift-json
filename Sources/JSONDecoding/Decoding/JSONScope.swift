/// A type that represents a scope for decoding operations.
public
protocol JSONScope
{
    /// Attempts to load a JSON variant value and passes it to the given
    /// closure, returns its result. If decoding fails, the implementation
    /// should annotate the error with appropriate context and re-throw it.
    func decode<T>(with decode:(JSON) throws -> T) throws -> T
}
extension JSONScope
{
    @inlinable public
    func decode<Decodable, T>(as _:Decodable.Type,
        with decode:(Decodable) throws -> T) throws -> T where Decodable:JSONDecodable
    {
        try self.decode { try decode(try .init(json: $0)) }
    }
    @inlinable public
    func decode<Decodable>(
        to _:Decodable.Type = Decodable.self) throws -> Decodable where Decodable:JSONDecodable
    {
        try self.decode(with: Decodable.init(json:))
    }
}
