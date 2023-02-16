extension JSON
{
    /// A thin wrapper around a native Swift array providing an efficient decoding
    /// interface for a JSON array.
    @frozen public
    struct Array
    {
        public
        var elements:[JSON]

        @inlinable public
        init(_ elements:[JSON])
        {
            self.elements = elements
        }
    }
}
extension JSON.Array
{
    /// Attempts to unwrap and parse a fixed-length array-decoder from this variant.
    /// 
    /// -   Returns:
    ///     The payload of this variant, parsed to an array-decoder, if it matches
    ///     ``case array(_:)``, could be successfully parsed, and contains the
    ///     expected number of elements.
    ///
    /// >   Throws:
    ///     An ``ArrayShapeError`` if an array was successfully unwrapped and 
    ///     parsed, but it did not contain the expected number of elements.
    @inlinable public 
    init(json:JSON, count:Int) throws
    {
        try self.init(try json.cast(with: \.array), count: count)
    }

    @inlinable public 
    init(_ elements:[JSON], count:Int) throws
    {
        self.init(elements)
        guard self.count == count 
        else 
        {
            throw JSON.ArrayShapeError.init(invalid: self.count, expected: count)
        }
    }

    /// Attempts to unwrap and parse an array-decoder from this variant, whose length 
    /// satifies the given criteria.
    /// 
    /// -   Returns:
    ///     The payload of this variant if it matches ``case array(_:)``, could be
    ///     successfully parsed, and contains the expected number of elements.
    ///
    /// >   Throws:
    ///     An ``ArrayShapeError`` if an array was successfully unwrapped and 
    ///     parsed, but it did not contain the expected number of elements.
    @inlinable public 
    init(json:JSON, where predicate:(_ count:Int) throws -> Bool) throws
    {
        try self.init(try json.cast(with: \.array), where: predicate)
    }

    @inlinable public 
    init(_ elements:[JSON], where predicate:(_ count:Int) throws -> Bool) throws
    {
        self.init(elements)
        guard try predicate(self.count)
        else 
        {
            throw JSON.ArrayShapeError.init(invalid: self.count)
        }
    }
}
extension JSON.Array:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.elements.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.elements.endIndex
    }
    @inlinable public
    subscript(index:Int) -> JSON.ExplicitField<Int>
    {
        .init(key: index, value: self.elements[index])
    }
}
