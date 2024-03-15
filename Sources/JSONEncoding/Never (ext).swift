import JSONAST

extension Never:JSONEncodable
{
    /// Does nothing.
    @inlinable public
    func encode(to _:inout JSON)
    {
    }
}
