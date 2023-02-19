extension JSON.Object
{
    @inlinable public
    init(fields:some Sequence<(key:String, value:some JSONEncodable)>)
    {
        self.init(fields.map { ($0.key, $0.value.encoded(as: JSON.self)) })
    }
}
extension JSON.Object
{
    /// Appends the given key-value pair to this object builder, encoding the
    /// given array elements as the field value, so long as it is not empty (or
    /// `elide` is [`false`]()).
    ///
    /// Type inference will always infer this subscript as long as any
    /// ``JSON.Array`` API is used within its builder closure.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the object,
    /// even if the key is the same.
    @inlinable public
    subscript(key:String, elide elide:Bool = false) -> JSON.Array?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:JSON.Array, !(elide && value.elements.isEmpty)
            {
                self.fields.append((key, value.encoded(as: JSON.self)))
            }
        }
    }

    /// Appends the given key-value pair to this object builder, encoding the
    /// given subobject as the field value, so long as it is not empty (or
    /// `elide` is [`false`]()).
    ///
    /// Type inference will always infer this subscript as long as any
    /// `Object` DSL API is used within its builder closure.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the object,
    /// even if the key is the same.
    @inlinable public
    subscript(key:String, elide elide:Bool = false) -> Self?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Self, !(elide && value.fields.isEmpty)
            {
                self.fields.append((key, value.encoded(as: JSON.self)))
            }
        }
    }

    /// Appends the given key-value pair to this object builder, encoding the
    /// given collection as the field value, so long as it is not empty (or
    /// `elide` is [`false`]()).
    ///
    /// Type inference will always prefer one of the concretely-typed subscript
    /// overloads over this one.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the object,
    /// even if the key is the same.
    @inlinable public
    subscript<Encodable>(key:String, elide elide:Bool) -> Encodable?
        where Encodable:JSONEncodable & Collection
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Encodable, !(elide && value.isEmpty)
            {
                self.fields.append((key, value.encoded(as: JSON.self)))
            }
        }
    }
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
    subscript<Value>(key:String) -> Value?
        where Value:JSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields.append((key, value.encoded(as: JSON.self)))
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
