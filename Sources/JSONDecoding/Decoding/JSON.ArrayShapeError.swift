extension JSON
{
    /// An array had an invalid scheme.
    @frozen public
    struct ArrayShapeError:Equatable, Error
    {
        public
        let count:Int
        public
        let expected:Int?

        @inlinable public
        init(invalid:Int, expected:Int? = nil)
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
        if let expected:Int = self.expected
        {
            return "invalid element count (\(self.count)), expected \(expected) elements"
        }
        else
        {
            return "invalid element count (\(self.count))"
        }
    }
}
