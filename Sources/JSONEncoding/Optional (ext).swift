import JSONAST

extension Optional:JSONEncodable where Wrapped:JSONEncodable
{
    /// Encodes the wrapped value if it exists, or an explicit `null` if it does not.
    @inlinable public
    func encode(to json:inout JSON)
    {
        if  let self
        {
            self.encode(to: &json)
        }
        else
        {
            json += JSON.Literal<Never?>.init(nil)
        }
    }
}
