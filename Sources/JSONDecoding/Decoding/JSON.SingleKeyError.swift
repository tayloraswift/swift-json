extension JSON
{
    @frozen public
    enum SingleKeyError<CodingKey>:Equatable, Error
    {
        case none
        case multiple
    }
}
extension JSON.SingleKeyError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .none:
            return "no keys in single-field object"
        case .multiple:
            return "multiple keys in single-field object"
        }
    }
}
