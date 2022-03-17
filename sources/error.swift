#if swift(>=5.5)
extension JSON.IntegerOverflowError:Sendable {}
extension JSON.InvalidUnicodeScalarError:Sendable {}
    
extension JSON.LintingError:Sendable {}
extension JSON.PrimitiveError:Sendable {}
extension JSON.RecursiveError:Sendable {}
#endif 
extension JSON 
{
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
    
    // this is distinct from `Grammar.IntegerOverflowError<T>`, and only thrown
    // by the conversions on `Number`. this is the error thrown by the `Decoder`
    // implementation.
    public
    struct IntegerOverflowError:Error, CustomStringConvertible 
    {
        public
        let number:Number
        
        #if swift(<5.6)
        public
        let type:Any.Type
        
        public 
        init(number:Number, overflows:Any.Type)
        {
            self.number = number 
            self.type   = overflows 
        }
        #else 
        @available(swift, deprecated: 5.6, message: "use the more strongly-typed `overflows` property")
        public
        var type:Any.Type { self.overflows }
        
        @available(swift, introduced: 5.6)
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
            #if swift(<5.6)
            return "integer literal '\(number)' overflows decoded type '\(self.type)'"
            #else 
            "integer literal '\(number)' overflows decoded type '\(self.overflows)'"
            #endif
        }
    }
    
    public 
    struct LintingError:TraceableErrorRoot 
    {
        public static 
        var namespace:String 
        {
            "linting error"
        }

        public 
        var message:String
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
    
    public 
    enum PrimitiveError:TraceableErrorRoot
    {
        public static 
        var namespace:String 
        {
            "primitive decoding error"
        }
        
        case matching(variant:JSON, as:Any.Type)
        case undefined(key:String, in:[String: JSON])
        
        public 
        var message:String 
        {
            switch self 
            {
            case .matching(variant: let json, as: let type):
                return "expected type '\(type)' does not match json value '\(json)'"
            case .undefined(key: let key, in: let items):
                return "undefined key '\(key)'; valid items are: \(items)"
            }
        }
    }
    public 
    enum RecursiveError:TraceableError 
    {
        public static 
        var namespace:String 
        {
            "nested decoding error"
        }
        
        case array(underlying:Error)
        case dictionary(underlying:Error, in:String)
        
        public 
        var context:[String] 
        {
            switch self 
            {
            case .array(underlying: _): 
                return ["while decoding array element at index (unknown)"]
            case .dictionary(underlying: _, in: let key): 
                return ["while decoding dictionary value for key '\(key)'"]
            }
        }
        public 
        var next:Error?
        {
            switch self 
            {
            case    .array     (underlying: let error), 
                    .dictionary(underlying: let error, in: _): 
                return error
            }
        }
    }
}
