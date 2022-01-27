<p align="center">
  <strong><em><code>json</code></em></strong><br><small>server-side swift submodule</small>
</p>

This is a non-resilient Swift submodule. It should be imported as a Git submodule, not an SPM package. 

**This submodule depends on**:

* [`grammar`](https://github.com/kelvin13/ss-grammar)

**This submodule will add the following top-level symbols to your namespace**:

* `enum JSON`

All declarations are `internal`.

example usage:

```swift
@main 
enum Main 
{
    struct Decimal:Codable  
    {
        let units:Int 
        let places:Int 
    }
    struct Number:Codable 
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
        let decoder:JSON.Decoder = try Grammar.parse(string, as: JSON.Decoder.self)
        let number:Number = try .init(from: decoder)
        print(number)
        
        let invalid:String = 
        """
        {"success":true,value:0.1}
        """
        do 
        {
            let _:JSON.Decoder = try Grammar.parse(invalid, as: JSON.Decoder.self)
        }
        catch let error 
        {
            print("expected error:")
            print(error)
        }
    }
}
```
```text
$ swift run

Number(success: true, value: ss_json.Main.Decimal(units: 1, places: 1))

expected error:
ss_json.Grammar.ExpectedTerminal<Swift.Character>: expected '"' (encountered 'v')
note: while parsing productionless rule (literal sequence at json.swift:259)
note: while parsing value of type 'String' by rule 'StringLiteral'
note: while parsing value of type '((), Item)' by rule '(Value, Item)'
note: while parsing value of type 'Dictionary<String, Value>' by rule 'Object'
note: while parsing value of type 'Decoder' by rule 'Decoder'
note: while parsing input sequence '{"success":true,value:0.1}'
```
