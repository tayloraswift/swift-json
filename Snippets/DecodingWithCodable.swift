import JSON
import JSONDecoding

struct Decimal:Codable  
{
    let units:Int 
    let places:Int 
}
struct Response:Codable 
{
    let success:Bool 
    let value:Decimal
}

let string:String = 
"""
{"success":true,"value":0.1}
"""
let decoder:JSON = try .init(parsing: string)
let response:Response = try .init(from: decoder)

print(response)
