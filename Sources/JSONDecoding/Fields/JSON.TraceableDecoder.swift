extension JSON
{
    /// A type that represents a scope for decoding operations.
    public
    protocol TraceableDecoder
    {
        /// Attempts to load a JSON variant value and passes it to the given
        /// closure, returns its result. If decoding fails, the implementation
        /// should annotate the error with appropriate context and re-throw it.
        func decode<T>(with decode:(JSON.Node) throws -> T) throws -> T
    }
}

extension JSON.TraceableDecoder
{
    @inlinable public
    func decode<CodingKey, T>(using _:CodingKey.Type = CodingKey.self,
        with decode:(JSON.ObjectDecoder<CodingKey>) throws -> T) throws -> T
    {
        try self.decode { try decode(try .init(json: $0)) }
    }
    @inlinable public
    func decode<T>(with decode:(JSON.ObjectDecoder<JSON.Key>) throws -> T) throws -> T
    {
        try self.decode { try decode(try .init(json: $0)) }
    }
    @inlinable public
    func decode<T>(with decode:(JSON.Array) throws -> T) throws -> T
    {
        try self.decode { try decode(try .init(json: $0)) }
    }

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
