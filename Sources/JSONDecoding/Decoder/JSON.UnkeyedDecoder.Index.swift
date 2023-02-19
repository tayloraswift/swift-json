extension JSON.UnkeyedDecoder
{
    struct Index:CodingKey 
    {
        let value:Int
        var intValue:Int? 
        {
            self.value 
        }
        var stringValue:String
        {
            "\(self.value)"
        }
        
        init(intValue:Int)
        {
            self.value = intValue
        }
        init?(stringValue:String)
        {
            guard let value:Int = Int.init(stringValue)
            else 
            {
                return nil 
            }
            self.value = value
        }
    }
}
