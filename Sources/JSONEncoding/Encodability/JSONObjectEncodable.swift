/// A type that can be encoded to a JSON object.
public
protocol JSONObjectEncodable:JSONEncodable
{
    func encode(to json:inout JSON.Object)
}
extension JSONObjectEncodable
{
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .object(.init(with: self.encode(to:)))
    }
}
