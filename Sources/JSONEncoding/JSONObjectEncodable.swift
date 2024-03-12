import JSONAST

public
protocol JSONObjectEncodable<CodingKey>:JSONEncodable
{
    associatedtype CodingKey:RawRepresentable<String> = JSON.Key

    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
}
extension JSONObjectEncodable
{
    @inlinable public
    func encode(to json:inout JSON)
    {
        self.encode(to: &json[as: JSON.ObjectEncoder<CodingKey>.self])
    }
}
