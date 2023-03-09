extension JSON.Object:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.fields.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.fields.endIndex
    }
    @inlinable public
    subscript(index:Int) -> JSON.ExplicitField<String>
    {
        let field:(key:JSON.Key, value:JSON) = self.fields[index]
        return .init(key: field.key.rawValue, value: field.value)
    }
}
extension JSON.Object:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        self = try json.cast(with: \.object)
    }
}
