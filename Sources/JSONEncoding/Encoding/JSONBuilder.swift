public
protocol JSONBuilder<CodingKey>
{
    associatedtype CodingKey

    mutating
    func append(_ key:CodingKey, _ value:some JSONEncodable)
}

extension JSONBuilder
{
    @inlinable public mutating
    func push(_ key:CodingKey, _ value:(some JSONEncodable)?)
    {
        value.map
        {
            self.append(key, $0)
        }
    }
    @available(*, deprecated, message: "use append(_:_:) for non-optional values")
    public mutating
    func push(_ key:CodingKey, _ value:some JSONEncodable)
    {
        self.append(key, value)
    }
}
extension JSONBuilder
{
    @inlinable public
    subscript(key:CodingKey, with encode:(inout JSON.Array) -> ()) -> Void
    {
        mutating get
        {
            self.append(key, JSON.Array.init(with: encode))
        }
    }
    @inlinable public
    subscript(key:CodingKey,
        with encode:(inout JSON.ObjectEncoder<JSON.Key>) -> ()) -> Void
    {
        mutating get
        {
            self.append(key, JSON.Object.init(with: encode))
        }
    }
    @inlinable public
    subscript<NestedKey>(key:CodingKey,
        using _:NestedKey.Type = NestedKey.self,
        with encode:(inout JSON.ObjectEncoder<NestedKey>) -> ()) -> Void
    {
        mutating get
        {
            self.append(key, JSON.Object.init(with: encode))
        }
    }
}

extension JSONBuilder
{
    /// Appends the given key-value pair to this object builder, encoding the
    /// value as the field value using its ``JSONEncodable`` implementation.
    ///
    /// Type inference will always prefer one of the concretely-typed subscript
    /// overloads over this one.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() assignment to this subscript (including mutations
    /// that leave the value in a non-[`nil`]() state after returning) will add
    /// a new field to the object, even if the key is the same.
    @inlinable public
    subscript<Value>(key:CodingKey) -> Value?
        where Value:JSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.push(key, value)
        }
    }
}
