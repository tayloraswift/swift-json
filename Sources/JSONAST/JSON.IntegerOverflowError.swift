extension JSON 
{
    /// @import(Grammar)
    /// An integer overflow occurred while converting a number literal to a desired type.
    /// 
    /// This error is thrown by decoders, and is different from
    /// ``Pattern.IntegerOverflowError``, which is thrown by the parser.
    public
    struct IntegerOverflowError:Error, Sendable 
    {
        /// The number literal that could not be converted.
        public
        let number:Number
        
        /// The metatype of the desired integer type.
        public
        let overflows:any FixedWidthInteger.Type
        
        public 
        init(number:Number, overflows:any FixedWidthInteger.Type)
        {
            self.number = number 
            self.overflows = overflows 
        }
    }
}
extension JSON.IntegerOverflowError
{
    @available(swift, deprecated: 5.7,
        message: "use the more strongly-typed 'overflows' property")
    public
    var type:Any.Type { self.overflows }
}
extension JSON.IntegerOverflowError:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.equals(number: rhs.number, overflows: rhs.overflows)
    }

    private
    func equals<Integer>(number:JSON.Number, overflows _:Integer.Type) -> Bool
        where Integer:FixedWidthInteger
    {
        self.number == number && self.overflows is Integer.Type
    }
}
extension JSON.IntegerOverflowError:CustomStringConvertible
{
    public
    var description:String 
    {
        "integer literal '\(number)' overflows decoded type '\(self.overflows)'"
    }
}
