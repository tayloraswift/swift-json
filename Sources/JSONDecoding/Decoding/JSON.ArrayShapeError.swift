extension JSON
{
    /// An array had an invalid scheme.
    @frozen public
    struct ArrayShapeError:Equatable, Error
    {
        public
        let count:Int
        public
        let expected:ArrayShapeCriteria?

        @inlinable public
        init(invalid:Int, expected:ArrayShapeCriteria? = nil)
        {
            self.count = invalid
            self.expected = expected
        }
    }
}
extension JSON.ArrayShapeError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self.expected
        {
        case nil:
            "Invalid element count (\(self.count))."
        
        case .count(let count)?:
            "Invalid element count (\(self.count)), expected \(count) elements."
        
        case .multiple(of: let stride)?:
            "Invalid element count (\(self.count)), expected multiple of \(stride)."
        }
    }
}
