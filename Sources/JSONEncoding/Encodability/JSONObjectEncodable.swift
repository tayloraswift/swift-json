/// A type that can be encoded to a JSON object.
public
protocol JSONObjectEncodable:JSONEncodable
{
    associatedtype CodingKey:RawRepresentable<String> & Hashable

    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
}
extension JSONObjectEncodable
{
    @inlinable public
    func encoded(as _:JSON.Type) -> JSON
    {
        .object(.init(encoding: self))
    }
}
