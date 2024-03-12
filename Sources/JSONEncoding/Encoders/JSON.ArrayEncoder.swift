import JSONAST

extension JSON
{
    @frozen public
    struct ArrayEncoder:Sendable
    {
        @usableFromInline internal
        var first:Bool
        @usableFromInline internal
        var json:JSON

        @inlinable internal
        init(json:JSON)
        {
            self.first = true
            self.json = json
        }
    }
}
extension JSON.ArrayEncoder:JSON.InlineEncoder
{
    @inlinable internal static
    func move(_ json:inout JSON) -> Self
    {
        json.utf8.append(0x5B) // '['
        defer { json.utf8 = [] }
        return .init(json: json)
    }
    @inlinable internal mutating
    func move() -> JSON
    {
        self.first = true
        self.json.utf8.append(0x5D) // ']'
        defer { self.json.utf8 = [] }
        return  self.json
    }
}
extension JSON.ArrayEncoder
{
    /// Creates a nested JSON encoding context.
    ///
    /// This accessor isn’t very useful on its own, rather, you should chain it with a call to
    /// ``JSON.subscript(_:_:)`` to bind the context to a particular coding key.
    ///
    /// You can also encode values directly with this accessor, via the `encode(to: &$0.next)`
    /// pattern, although the ``subscript(_:)`` setter is probably more convenient for that.
    @inlinable public
    var next:JSON
    {
        _read
        {
            yield .init(utf8: [])
        }
        _modify
        {
            if  self.first
            {
                self.first = false
            }
            else
            {
                self.json.utf8.append(0x2C) // ','
            }

            yield &self.json
        }
    }

    /// Creates a nested object encoding context.
    @inlinable public mutating
    func callAsFunction<Key>(_:Key.Type = Key.self,
        _ yield:(inout JSON.ObjectEncoder<Key>) -> ())
    {
        yield(&self.next[as: JSON.ObjectEncoder<Key>.self])
    }

    /// Creates a nested array encoding context.
    @inlinable public mutating
    func callAsFunction(
        _ yield:(inout JSON.ArrayEncoder) -> ())
    {
        yield(&self.next[as: Self.self])
    }

    /// Appends a value to the array.
    ///
    /// Why a subscript and not an `append` method? Because we often want to optionally append a
    /// value while building an array, and the subscript syntax is more convenient for that.
    @inlinable public
    subscript<Encodable>(_:(Index) -> Void) -> Encodable? where Encodable:JSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self.next) }
    }
}
