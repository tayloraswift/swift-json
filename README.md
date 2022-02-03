<p align="center">
  <strong><em><code>json</code></em></strong><br><small><code>0.1.0</code></small>
</p>

`JSON` is a pure-Swift JSON parsing library designed for high-performance, high-throughput server-side applications. 

example usage:

```swift
import JSON 

@main 
enum Main 
{
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
    static 
    func main() throws
    {
        let string:String = 
        """
        {"success":true,"value":0.1}
        """
        let decoder:JSON        = 
            try Grammar.parse(string.utf8, as: JSON.Rule<String.Index>.Root.self)
        let response:Response  = 
            try .init(from: decoder)
        
        print(response)
        
        let invalid:String = 
        """
        {"success":true,value:0.1}
        """
        do 
        {
            let _:JSON = 
                try Grammar.parse(diagnosing: invalid.utf8, as: JSON.Rule<String.Index>.Root.self)
        }
        catch let error as ParsingError<String.Index> 
        {
            print(error.annotate(source: invalid, line: String.init(_:), newline: \.isNewline))
        }
    }
}

```
```text
$ .build/release/examples
Response(success: true, value: JSONExamples.Main.Decimal(units: 1, places: 1))

JSON.Grammar.Expected<(extension in JSON):JSON.Grammar.Encoding<Swift.String.Index, Swift.UInt8>.ASCII.Quote>: expected construction by rule 'Quote'
{"success":true,value:0.1}
                ^
note: expected pattern '(extension in JSON):JSON.Grammar.Encoding<Swift.String.Index, Swift.UInt8>.ASCII.Quote'
{"success":true,value:0.1}
                ^
note: while parsing value of type 'Swift.String' by rule 'JSON.JSON.Rule<Swift.String.Index>.StringLiteral'
{"success":true,value:0.1}
                ^
note: while parsing value of type '((), (key: Swift.String, value: JSON.JSON))' by rule '(JSON.Grammar.Pad<(extension in JSON):JSON.Grammar.Encoding<Swift.String.Index, Swift.UInt8>.ASCII.Comma, JSON.JSON.Rule<Swift.String.Index>.Whitespace>, JSON.JSON.Rule<Swift.String.Index>.Object.Item)'
{"success":true,value:0.1}
               ^~
note: while parsing value of type 'Swift.Dictionary<Swift.String, JSON.JSON>' by rule 'JSON.JSON.Rule<Swift.String.Index>.Object'
{"success":true,value:0.1}
^~~~~~~~~~~~~~~~~
note: while parsing value of type 'JSON.JSON' by rule 'JSON.JSON.Rule<Swift.String.Index>.Root'
{"success":true,value:0.1}
^~~~~~~~~~~~~~~~~

```
