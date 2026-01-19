import JSON

//  snippet.MARKETTYPE_ENUM
enum MarketType: String {
    case spot
    case future
}
//  snippet.MARKETTYPE_DECODABLE
extension MarketType: JSONDecodable {
}
//  snippet.MARKET
struct Market {
    let name: String
    let type: MarketType
    let isPerpetual: Bool

    private init(name: String, type: MarketType, isPerpetual: Bool) {
        self.name = name
        self.type = type
        self.isPerpetual = isPerpetual
    }
}
// snippet.MARKET_CODING_KEY
extension Market {
    enum CodingKey: String {
        case name
        case type
        case perpetual
    }
}
//  snippet.MARKET_DECODE
extension Market: JSONObjectDecodable {
    init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            name: try json[.name].decode(),
            type: try json[.type].decode(),
            isPerpetual: try json[.perpetual]?.decode() ?? false
        )
    }
}
//  snippet.MAIN
func decode(message: String) throws -> Market {
    // snippet.MAIN_PARSE_AND_INDEX
    let object: JSON.Object = try .init(parsing: message)
    let json: JSON.ObjectDecoder<JSON.Key> = try .init(indexing: object)

    // snippet.MAIN_DECODE
    return try json["market"].decode()
    // snippet.end
}
// snippet.MAIN_CALL
print(try decode(message: """
        {
            "market": {
                "name": "BTC-PERP",
                "type": "future",
                "perpetual": true
            }
        }
        """))

print(try decode(message: """
        {
            "market": {
                "name": "BTC-PERP",
                "type": "spot"
            }
        }
        """))
