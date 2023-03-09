import JSON
import JSONDecoding

// snippet.market-enum-definition
enum Market:String 
{
    case spot 
    case future 
}
extension Market:JSONDecodable
{
}
// snippet.main
func decode(message:String) throws -> 
(
    name:String, 
    market:Market, 
    isPerpetual:Bool 
)
{
    // snippet.parse
    let object:JSON.Object = try .init(parsing: message)
    // snippet.index
    let json:JSON.ObjectDecoder<JSON.Key> = try .init(object: object)
    // snippet.decode 
    return try json["market"].decode(as: JSON.ObjectDecoder<JSON.Key>.self)
    {
        // snippet.decode-string
        let name:String = try $0["name"].decode(to: String.self)
        // snippet.decode-enum
        let market:Market = try $0["type"].decode(to: Market.self)
        // snippet.decode-elided
        let isPerpetual:Bool = try $0["perpetual"]?.decode(to: Bool.self) ?? false 
        // snippet.return
        return (name, market, isPerpetual)
    }
    // snippet.hide
}
print(try decode(message: 
"""
{
    "market": 
    {
        "name": "BTC-PERP",
        "type": "future",
        "perpetual": true
    }
}
"""))

print(try decode(message: 
"""
{
    "market": 
    {
        "name": "BTC-PERP",
        "type": "spot"
    }
}
"""))
