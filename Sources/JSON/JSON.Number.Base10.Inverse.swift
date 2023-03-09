extension JSON.Number.Base10
{
    /// Negative powers of 10, down to [`1e-19`]().
    enum Inverse 
    {
        /// Returns the inverse of the given power of 10.
        /// -   Parameters:
        ///     - x: A positive exponent. If `x` is [`2`](), this subscript 
        ///         will return [`1e-2`]().
        ///     - _: A ``BinaryFloatingPoint`` type.
        static 
        subscript<T>(x:Int, as _:T.Type) -> T 
            where T:BinaryFloatingPoint
        {
            let inverses:[T] = 
            [
                1, 
                1e-1, 
                1e-2, 
                
                1e-3,
                1e-4, 
                1e-5, 
                
                1e-6, 
                1e-7,
                1e-8,
                
                1e-9, 
                1e-10,
                1e-11,
                
                1e-12, 
                1e-13,
                1e-14,
                
                1e-15, 
                1e-16,
                1e-17,
                
                1e-18, 
                1e-19,
            ]
            return inverses[x]
        }
    }
}
