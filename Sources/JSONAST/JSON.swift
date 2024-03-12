@frozen public
struct JSON:Sendable
{
    public
    var utf8:ArraySlice<UInt8>

    @inlinable public
    init(utf8:ArraySlice<UInt8>)
    {
        self.utf8 = utf8
    }
}
extension JSON:CustomStringConvertible
{
    public
    var description:String
    {
        .init(decoding: self.utf8, as: UTF8.self)
    }
}
