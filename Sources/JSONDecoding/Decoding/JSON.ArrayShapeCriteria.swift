extension JSON
{
    /// What shape you expected an array to have.
    @frozen public
    enum ArrayShapeCriteria:Hashable, Sendable
    {
        case count(Int)
        case multiple(of:Int)
    }
}
