import JSON 

// ``JSON//LintingDictionary`` provides a lightweight functional interface 
// for decoding JSON messages with built-in error handling.

// snippet.market-enum-definition
enum Market:String 
{
    case spot 
    case future 
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
    let json:JSON = try Grammar.parse(message.utf8, 
        as: JSON.Rule<String.Index>.Root.self)
    // snippet.decode 
    return try json.lint 
    {
        try $0.remove("market") 
        {
            try $0.lint 
            {
                // snippet.decode-string
                let name:String = try $0.remove("name", as: String.self)


                // snippet.decode-enum
                let market:Market = try $0.remove("type") 
                { 
                    try $0.as(cases: Market.self) 
                }

                // snippet.decode-conditional
                let isPerpetual:Bool
                if case .future = market 
                {
                    isPerpetual = try $0.pop("perpetual", as: Bool.self) ?? false 
                }
                else 
                {
                    isPerpetual = false 
                }
                // snippet.return
                return (name, market, isPerpetual)
            }
        }
    }
}
// snippet.example-success
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

// snippet.example-failure
print(try decode(message: 
"""
{
    "market": 
    {
        "name": "BTC-PERP",
        "type": "spot",
        "perpetual": true
    }
}
"""))

// snippet.hide 
extension JSON.LintingDictionary 
{
    private mutating 
    func lintArrays(_ key:String, as _:[JSON].Type, _ body:([JSON]) throws -> ()) throws 
    {
        // snippet.pop-array-equivalence 
        try self.pop(key)
        {
            try body(try $0.as([JSON].self))
        }
        // snippet.hide 
        // snippet.pop-array-or-null-equivalence 
        try self.pop(key)
        {
            try $0.as([JSON]?.self).map(body)
        } ?? nil 
        // snippet.hide 
        // snippet.remove-array-equivalence 
        try self.remove(key) 
        { 
            try body(try $0.as([JSON].self)) 
        }
        // snippet.hide 
        // snippet.remove-array-or-nullequivalence 
        try self.remove(key) 
        { 
            try $0.as([JSON]?.self).map(body) 
        }
        // snippet.hide 
    }
}