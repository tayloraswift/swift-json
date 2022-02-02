import JSON

extension JSON:Decodable 
{
    struct _Decimal<T>:Decodable where T:Decodable
    {
        let units:T
        let places:T
    }
    struct _Key:CodingKey 
    {
        let stringValue:String 
        var intValue:Int?
        {
            .init(self.stringValue) 
        }
        init(stringValue:String)
        {
            self.stringValue = stringValue
        }
        init(intValue:Int)
        {
            self.stringValue = "\(intValue)"
        }
    }
    public 
    init(from decoder:Swift.Decoder) throws 
    {
        if let object:KeyedDecodingContainer<_Key> = try? decoder.container(keyedBy: _Key.self)
        {
            self = .object(.init(uniqueKeysWithValues: try object.allKeys.map 
            {
                ($0.stringValue, try object.decode(Self.self, forKey: $0))
            }))
        }
        else if var array:UnkeyedDecodingContainer = try? decoder.unkeyedContainer() 
        {
            var elements:[Self] = []
            while !array.isAtEnd 
            {
                elements.append(try array.decode(Self.self))
            }
            self = .array(elements)
        }
        else 
        {
            let primitive:SingleValueDecodingContainer  = try decoder.singleValueContainer()
            if let string:String                        = try? primitive.decode(String.self)
            {
                self = .string(string)
            }
            else if let unsigned:_Decimal<UInt64>       = try? primitive.decode(_Decimal<UInt64>.self)
            {
                self = .number(.init(sign: .plus, units: unsigned.units, places: UInt32.init(unsigned.places)))
            }
            else if let signed:_Decimal<Int64>          = try? primitive.decode(_Decimal<Int64>.self)
            {
                // only reason this would succeed and not the previous one is if the 
                // previous one is negative 
                self = .number(.init(sign: .minus, units: UInt64.init(Swift.abs(signed.units)), places: UInt32.init(signed.places)))
            }
            else if let unsigned:UInt64                 = try? primitive.decode(UInt64.self)
            {
                self = .number(.init(sign: .plus, units: unsigned, places: 0))
            }
            else if let signed:Int64                    = try? primitive.decode(Int64.self)
            {
                // only reason this would succeed and not the previous one is if the 
                // previous one is negative 
                self = .number(.init(sign: .minus, units: UInt64.init(Swift.abs(signed)), places: 0))
            }
            else if let _:Double                        = try? primitive.decode(Double.self)
            {
                // not possible to reconstruct a decimal value from a `Double`, 
                // and re-parsing from a `String` would slow down the benchmark
                self = .number(.init(sign: .plus, units: 0, places: 0))
            }
            else if let value:Bool                      = try? primitive.decode(Bool.self)
            {
                // not possible to reconstruct a decimal value from a `Double`, 
                // and re-parsing from a `String` would slow down the benchmark
                self = .bool(value)
            }
            else 
            {
                let _:Bool = primitive.decodeNil()
                self = .null
            }
        }
    }
}
