extension JSON
{
    /// An efficient interface for checking the length of a decoded
    /// array at run time.
    @frozen public
    struct ArrayShape:Hashable, Sendable
    {
        public
        let count:Int

        @inlinable public
        init(count:Int)
        {
            self.count = count
        }
    }
}
extension JSON.ArrayShape
{
    /// Throws an ``ArrayShapeError`` if the relevant array does not
    /// contain the specified number of elements.
    @inlinable public
    func expect(count:Int) throws
    {
        guard self.count == count 
        else 
        {
            throw JSON.ArrayShapeError.init(invalid: self.count, expected: .count(count))
        }
    }
    /// Throws an ``ArrayShapeError`` if the number of elements in the
    /// relevant array is not a multiple of the specified stride.
    @inlinable public
    func expect(multipleOf stride:Int) throws
    {
        guard self.count.isMultiple(of: stride)
        else 
        {
            throw JSON.ArrayShapeError.init(invalid: self.count,
                expected: .multiple(of: stride))
        }
    }
    /// Converts a boolean status code into a thrown ``ArrayShapeError``.
    /// To generate an error, return false from the closure.
    @inlinable public 
    func expect(that predicate:(_ count:Int) throws -> Bool) throws
    {
        guard try predicate(self.count)
        else 
        {
            throw JSON.ArrayShapeError.init(invalid: self.count)
        }
    }
}
