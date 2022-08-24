import JSON 

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
let decoder:JSON = try .init(parsing: string.utf8)
let response:Response = try .init(from: decoder)

print(response)

let invalid:String = 
"""
{"success":true,value:0.1}
"""
do 
{
    let _:JSON = try JSON.Rule<String.Index>.Root.parse(diagnosing: invalid.utf8)
}
catch let error as ParsingError<String.Index> 
{
    let debug:String = error.annotate(source: invalid, 
        line: String.init(_:), newline: \.isNewline)
    print(debug)
}
