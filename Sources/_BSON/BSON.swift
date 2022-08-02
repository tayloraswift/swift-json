@frozen public
enum BSON 
{
    @frozen public 
    struct ObjectIdentifier
    {
        public 
        var timestamp:UInt32 
        public 
        var seed:
        (
            UInt8, 
            UInt8, 
            UInt8, 
            UInt8, 
            UInt8
        )
        public 
        var index:
        (
            UInt8, 
            UInt8, 
            UInt8
        )
    }
    @frozen public 
    struct Regex
    {
        @frozen public 
        struct Options:OptionSet 
        {
            public 
            var rawValue:UInt8 

            @inlinable public 
            init(rawValue:UInt8)
            {
                self.rawValue = rawValue
            }

            static 
            let i:Self = .init(rawValue: 1 << 0)
            static 
            let l:Self = .init(rawValue: 1 << 1)
            static 
            let m:Self = .init(rawValue: 1 << 2)
            static 
            let s:Self = .init(rawValue: 1 << 3)
            static 
            let u:Self = .init(rawValue: 1 << 4)
            static 
            let x:Self = .init(rawValue: 1 << 5)
        }

        public 
        var pattern:String 
        public 
        var options:Options
    }
    @frozen public 
    struct Decimal128
    {
        public 
        var low:UInt64
        public 
        var high:UInt64 
    }
    @frozen public 
    struct BinarySubtype:RawRepresentable 
    {
        public 
        var rawValue:UInt8

        @inlinable public 
        init(rawValue:UInt8)
        {
            self.rawValue = rawValue
        }
    }

    case array(ArraySlice<UInt8>)
    case bool(Bool)
    case bytes([UInt8], of:BinarySubtype)
    case decimal128(Decimal128)
    case document(ArraySlice<UInt8>)
    case double(Double)
    case id(ObjectIdentifier)
    case int32(Int32)
    case int64(Int64)
    case javascript(String)
    case max 
    case millisecond(Int64)
    case min 
    case null 
    case regex(Regex)
    case string(String)
    case uint64(UInt64)
}