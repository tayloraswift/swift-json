extension JSON.Array
{
    @inlinable public
    var shape:JSON.ArrayShape
    {
        .init(count: self.count)
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
    subscript(index:Int) -> JSON.FieldDecoder<Int>
    {
        .init(key: index, value: self.elements[index])
    }
}
extension JSON.Array:JSONDecodable
{
    @inlinable public
    init(json:JSON.Node) throws
    {
        self = try json.cast(with: \.array)
    }
}
