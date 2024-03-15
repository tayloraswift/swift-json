extension JSON
{
    /// An object had an invalid key scheme.
    @frozen public
    enum ObjectKeyError<CodingKey>:Error where CodingKey:Sendable
    {
        /// An object contained more than one field with the same key.
        case duplicate(CodingKey)
        /// An object did not contain a field with the expected key.
        case undefined(CodingKey)
    }
}
extension JSON.ObjectKeyError:Equatable where CodingKey:Equatable
{
}
extension JSON.ObjectKeyError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .duplicate(let key):
            "duplicate key '\(key)'"
        case .undefined(let key):
            "undefined key '\(key)'"
        }
    }
}
