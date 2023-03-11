import TraceableErrors

extension JSON
{
    /// An error occurred while decoding a document field.
    @frozen public
    struct DecodingError<Location>:Error
    {
        /// The location (key or index) where the error occurred.
        public
        let location:Location
        /// The underlying error that occurred.
        public
        let underlying:any Error

        @inlinable public
        init(_ underlying:any Error, in location:Location)
        {
            self.location = location
            self.underlying = underlying
        }
    }
}
extension JSON.DecodingError:Equatable where Location:Equatable
{
    /// Compares the ``location`` properties and the ``underlying``
    /// errors of the operands for equality, returning [`true`]()
    /// if they are equal. Always returns [`false`]() if (any of)
    /// the underlying ``Error`` existentials are not ``Equatable``.
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.location == rhs.location &&
        lhs.underlying == rhs.underlying
    }
}
extension JSON.DecodingError:TraceableError
{
    /// Returns a single note that says
    /// [`"while decoding value for field '_'"`]().
    public 
    var notes:[String] 
    {
        ["while decoding value for field '\(self.location)'"]
    }
}
