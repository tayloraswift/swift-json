extension JSON.Number
{
    /// A namespace for decimal-related functionality.
    /// 
    /// This API is used by library functions that are emitted into the client. 
    /// Most users of ``/swift-json`` should not have to call it directly.
    public 
    enum Base10
    {
        /// Positive powers of 10, up to [`10_000_000_000_000_000_000`]().
        public static
        let Exp:[UInt64] = 
        [
            1, 
            10, 
            100, 
            
            1_000,
            10_000, 
            100_000, 
            
            1_000_000, 
            10_000_000,
            100_000_000,
            
            1_000_000_000, 
            10_000_000_000,
            100_000_000_000,
            
            1_000_000_000_000, 
            10_000_000_000_000,
            100_000_000_000_000,
            
            1_000_000_000_000_000, 
            10_000_000_000_000_000,
            100_000_000_000_000_000,
            
            1_000_000_000_000_000_000, 
            10_000_000_000_000_000_000,
            //  UInt64.max: 
            //  18_446_744_073_709_551_615
        ]
    }
}
