extension JSON
{
    /// An object had an invalid key scheme.
    @frozen public
    enum DictionaryKeyError:Equatable, Error
    {
        /// An object contained more than one field with the same key.
        case duplicate(String)
        /// An object did not contain a field with the expected key.
        case undefined(String)
    }
}
extension JSON.DictionaryKeyError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .duplicate(let key):
            return "duplicate key '\(key)'"
        case .undefined(let key):
            return "undefined key '\(key)'"
        }
    }
}
