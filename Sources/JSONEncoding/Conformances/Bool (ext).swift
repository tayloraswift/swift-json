import JSONAST

extension Bool:JSONEncodable
{
    @inlinable public
    func encode(to json:inout JSON)
    {
        json += JSON.Literal<Bool>.init(self)
    }
}
