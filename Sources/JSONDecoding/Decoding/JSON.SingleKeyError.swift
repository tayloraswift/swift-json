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
            "no keys in single-field object"
        case .multiple:
            "multiple keys in single-field object"
        }
    }
}
