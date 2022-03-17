extension JSON 
{
    @inlinable public
    func `case`<T>(of _:T.Type) throws -> T 
        where T:RawRepresentable, T.RawValue == String
    {
        if let value:T = T.init(rawValue: try self.as(String.self))
        {
            return value
        }
        else 
        {
            throw PrimitiveError.matching(variant: self, as: T.self)
        }
    }
}
