extension Set:JSONDecodable where Element:JSONDecodable
{
    @inlinable public
    init(json:JSON.Node) throws
    {
        let array:JSON.Array = try .init(json: json)

        self.init()
        self.reserveCapacity(array.count)
        for field:JSON.FieldDecoder<Int> in array
        {
            self.update(with: try field.decode(to: Element.self))
        }
    }
}
