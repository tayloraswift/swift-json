import TraceableErrors

#if swift(>=5.5)
extension JSON.IntegerOverflowError:Sendable {}
extension JSON.InvalidUnicodeScalarError:Sendable {}
    
extension JSON.LintingError:Sendable {}
extension JSON.PrimitiveError:Sendable {}
extension JSON.RecursiveError:Sendable {}
#endif 
extension JSON 
{
    /// A string literal contained a unicode escape sequence that does not encode a 
    /// valid ``Unicode/Scalar``.
    /// 
    /// This error is thrown by the parser. Decoders should not use it.
    public 
    struct InvalidUnicodeScalarError:Error
    {
        public
        let value:UInt16  
        @inlinable public 
        init(value:UInt16)
        {
            self.value = value
        }
    }
    /// @import(Grammar)
    /// An integer overflow occurred while converting a number literal to a desired type.
    /// 
    /// This error is thrown by decoders, and is different from ``Pattern/IntegerOverflowError``, 
    /// which is thrown by the parser.
    public
    struct IntegerOverflowError:Error, CustomStringConvertible 
    {
        /// The number literal that could not be converted.
        public
        let number:Number
        
        #if swift(<5.7)
        public
        let type:Any.Type
        
        public 
        init(number:Number, overflows:Any.Type)
        {
            self.number = number 
            self.type   = overflows 
        }
        #else 
        @available(swift, deprecated: 5.7, message: "use the more strongly-typed `overflows` property")
        public
        var type:Any.Type { self.overflows }
        
        /// The metatype of the desired integer type.
        @available(swift, introduced: 5.7)
        public
        let overflows:any FixedWidthInteger.Type
        
        public 
        init(number:Number, overflows:any FixedWidthInteger.Type)
        {
            self.number = number 
            self.overflows = overflows 
        }
        #endif
        
        public
        var description:String 
        {
            #if swift(<5.7)
            return "integer literal '\(number)' overflows decoded type '\(self.type)'"
            #else 
            "integer literal '\(number)' overflows decoded type '\(self.overflows)'"
            #endif
        }
    }
    /// A decoder did not consume, discard, or whitelist all the available keys
    /// in a JSON object.
    public 
    struct LintingError:Error, CustomStringConvertible
    {
        public 
        var description:String
        {
            "unused object items \(self.unused)"
        }
        
        public 
        let unused:[String: JSON]
        public 
        init(unused:[String: JSON])
        {
            self.unused = unused
        }
    }
    /// A primitive decoding operation failed.
    public 
    enum PrimitiveError:Error, CustomStringConvertible
    {
        /// A decoder successfully unwrapped an array, but it had the wrong number of elements.
        case shaping(aggregate:[JSON], count:Int? = nil)
        /// A decoder failed to unwrap the expected type from a variant.
        case matching(variant:JSON, as:Any.Type)
        /// An object did not contain the expected key.
        case undefined(key:String, in:[String: JSON])
        
        public 
        var description:String 
        {
            switch self 
            {
            case .shaping(aggregate: let aggregate, count: let count?):
                return "could not unwrap aggregate from variant array '\(aggregate)' (expected \(count) elements)"
            case .shaping(aggregate: let aggregate, count: nil):
                return "could not unwrap aggregate from variant array '\(aggregate)'"
            case .matching(variant: let json, as: let type):
                return "could not unwrap type '\(type)' from variant '\(json)'"
            case .undefined(key: let key, in: let items):
                return "undefined key '\(key)'; valid items are: \(items)"
            }
        }
    }
    /// An error occurred while performing a decoding operation on an element of 
    /// an array or object.
    public 
    enum RecursiveError:TraceableError 
    {
        /// An error occurred while decoding an element of an array.
        case array(underlying:Error, at:Int)
        /// An error occurred while decoding a field of an object.
        case dictionary(underlying:Error, in:String)

        @available(*, deprecated, message: "Specify an explicit index with ``array(underlying:at:)``.")
        public static 
        func array(underlying:Error) -> Self 
        {
            .array(underlying: underlying, at: 0)
        }

        public 
        var notes:[String] 
        {
            switch self 
            {
            case .array(underlying: _, at: let index): 
                return ["while decoding array element at index \(index)"]
            case .dictionary(underlying: _, in: let key): 
                return ["while decoding dictionary value for key '\(key)'"]
            }
        }
        /// The underlying error that occurred.
        public 
        var underlying:Error
        {
            switch self 
            {
            case    .array     (underlying: let error, at: _), 
                    .dictionary(underlying: let error, in: _): 
                return error
            }
        }
    }
}
