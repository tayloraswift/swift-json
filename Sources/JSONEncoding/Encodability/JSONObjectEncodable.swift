/// A type that can be encoded to a JSON object.
public
protocol JSONObjectEncodable:JSONEncodable
{
    associatedtype CodingKeys:RawRepresentable<String> & Hashable

    func encode(to json:inout JSON.ObjectEncoder<CodingKeys>)
}
extension JSONObjectEncodable
{
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .object(.init(encoding: self))
    }
}
