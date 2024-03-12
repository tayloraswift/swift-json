import JSONAST

extension JSON
{
    @frozen public
    struct ObjectEncoder<Key>:Sendable
    {
        @usableFromInline
        var first:Bool
        @usableFromInline
        var json:JSON

        @inlinable
        init(json:JSON)
        {
            self.first = true
            self.json = json
        }
    }
}
extension JSON.ObjectEncoder:JSON.InlineEncoder
{
    @inlinable static
    func move(_ json:inout JSON) -> Self
    {
        json.utf8.append(0x7B) // '{'
        defer { json.utf8 = [] }
        return .init(json: json)
    }
    @inlinable mutating
    func move() -> JSON
    {
        self.first = true
        self.json.utf8.append(0x7D) // '}'
        defer { self.json.utf8 = [] }
        return  self.json
    }
}
extension JSON.ObjectEncoder
{
    @inlinable
    subscript(with key:String) -> JSON
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

            self.json += JSON.Literal<String>.init(key)
            self.json.utf8.append(0x3A) // ':'

            yield &self.json
        }
    }
}
extension JSON.ObjectEncoder<Any>
{
    @inlinable public
    subscript(key:String) -> JSON
    {
        _read   { yield  self[with: key] }
        _modify { yield &self[with: key] }
    }

    @inlinable public
    subscript<NestedKey>(key:String, yield:(inout JSON.ObjectEncoder<NestedKey>) -> ()) -> Void
    {
        mutating
        get { yield(&self[key][as: JSON.ObjectEncoder<NestedKey>.self]) }
    }

    @inlinable public
    subscript(key:String, yield:(inout JSON.ArrayEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self[with: key][as: JSON.ArrayEncoder.self]) }
    }

    @inlinable public
    subscript<Encodable>(key:String) -> Encodable? where Encodable:JSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self[with: key]) }
    }
}
extension JSON.ObjectEncoder where Key:RawRepresentable<String>
{
    @inlinable public
    subscript(key:Key) -> JSON
    {
        _read   { yield  self[with: key.rawValue] }
        _modify { yield &self[with: key.rawValue] }
    }

    @inlinable public
    subscript<NestedKey>(key:Key, yield:(inout JSON.ObjectEncoder<NestedKey>) -> ()) -> Void
    {
        mutating
        get { yield(&self[key][as: JSON.ObjectEncoder<NestedKey>.self]) }
    }

    @inlinable public
    subscript(key:Key, yield:(inout JSON.ArrayEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self[key][as: JSON.ArrayEncoder.self]) }
    }

    @inlinable public
    subscript<Encodable>(key:Key) -> Encodable? where Encodable:JSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self[key]) }
    }
}
