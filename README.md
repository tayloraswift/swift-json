<p align="center">
  <strong><em><code>json</code></em></strong><br><small><code>0.1.0</code></small>
</p>

`swift-json` is a pure-Swift JSON parsing library designed for high-performance, high-throughput server-side applications. When compared using the test data [`captured.json`](cases/), `swift-json` is nearly 7 times faster than `Foundation.JSONDecoder` ([see benchmark source code](benchmarks/)).

## example usage

The `JSON` module in `swift-json` enables you to express JSON parsing tasks as **constructive parsers**. This makes the `JSON` module very flexible without requiring much configuration from users who simply want to parse a JSON message from a remote peer.

To parse a complete JSON message, use the `JSON.Rule<Location>.Root` parsing rule:

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
        let decoder:JSON        = try Grammar.parse(string.utf8, 
            as: JSON.Rule<String.Index>.Root.self)
        let response:Response   = try .init(from: decoder)
        
        print(response)
        
        let invalid:String = 
        """
        {"success":true,value:0.1}
        """
        do 
        {
            let _:JSON = try Grammar.parse(diagnosing: invalid.utf8, 
                as: JSON.Rule<String.Index>.Root.self)
        }
        catch let error as ParsingError<String.Index> 
        {
            let debug:String = error.annotate(source: invalid, 
                line: String.init(_:), newline: \.isNewline)
            print(debug)
        }
    }
}
```
```text
$ .build/release/examples
Response(success: true, value: 
    JSONExamples.Main.Decimal(units: 1, places: 1))

Grammar.Expected<Grammar.Encoding.ASCII.Quote>: 
    expected construction by rule 'Quote'
{"success":true,value:0.1}
                ^
note: expected pattern 'Grammar.Encoding.ASCII.Quote'
{"success":true,value:0.1}
                ^
note: while parsing value of type 'String' by rule 
    'JSON.Rule.StringLiteral'
{"success":true,value:0.1}
                ^
note: while parsing value of type '((), (key: String, value: JSON))' 
    by rule '(Grammar.Pad<Grammar.Encoding.ASCII.Comma, 
    JSON.Rule.Whitespace>, JSON.Rule.Object.Item)'
{"success":true,value:0.1}
               ^~
note: while parsing value of type '[String: JSON]' by rule 
    'JSON.Rule.Object'
{"success":true,value:0.1}
^~~~~~~~~~~~~~~~~
note: while parsing value of type 'JSON' by rule 'JSON.Rule.Root'
{"success":true,value:0.1}
^~~~~~~~~~~~~~~~~
```

The `JSON` module supports parsing JSON fragments using the `JSON.Rule<Location>.Value` rule. 

The nature of constructive parsing also means it is straightforward to parse *multiple* concatenated JSON messages, as is commonly encountered when interfacing with streaming JSON APIs.

## adding `swift-json` as a dependency 

To use `swift-json` in a project, add the following to your `Package.swift` file:

```swift
let package = Package(
    ...
    dependencies: 
    [
        // other dependencies
        .package(url: "https://github.com/kelvin13/ss-json", from: "0.1.0"),
    ],
    targets: 
    [
        .target(name: "example", 
            dependencies: 
            [
                // other dependencies
                .product(name: "JSON", package: "swift-json"),
            ]),
        // other targets
    ]
)
```
