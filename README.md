<div align="center">
  
***`json`***<br>`0.2.2`
  
[![ci build status](https://github.com/kelvin13/swift-json/actions/workflows/build.yml/badge.svg)](https://github.com/kelvin13/swift-json/actions/workflows/build.yml)
[![ci windows build status](https://github.com/kelvin13/swift-json/actions/workflows/build-windows.yml/badge.svg)](https://github.com/kelvin13/swift-json/actions/workflows/build-windows.yml)

[![swift package index versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkelvin13%2Fswift-json%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kelvin13/swift-json)
[![swift package index platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkelvin13%2Fswift-json%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kelvin13/swift-json)

</div>

`swift-json` is a pure-Swift JSON parsing library designed for high-performance, high-throughput server-side applications. When compared using the test data [`captured.json`](cases/), `swift-json` is nearly 7 times faster than `Foundation.JSONDecoder` ([see benchmark source code](benchmarks/)).

**Importing this module will expose the following top-level symbol(s)**:

* `enum JSON`

**In addition, this module re-exports the following top-level symbol(s) from the `Grammar` module of [`swift-grammar`](https://github.com/kelvin13/swift-grammar)**:

* `enum Grammar`
* `protocol TraceableError`
* `protocol TraceableErrorRoot`
* `struct ParsingError<Index>`
* `struct ParsingInput<Diagnostics>`
* `protocol ParsingDiagnostics`
* `protocol ParsingRule`
* `protocol TerminalRule`
* `protocol LiteralRule`
* `protocol DigitRule`
* `protocol ASCIITerminal`
* `protocol UTF8Terminal`
* `protocol UTF16Terminal`
* `protocol UnicodeTerminal`
* `protocol CharacterTerminal`

**This module has library interfaces:**

* `@_spi(experimental)`

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
        .package(url: "https://github.com/kelvin13/swift-json", from: "0.2.2"),
    ],
    targets: 
    [
        .target(name: "example", 
            dependencies: 
            [
                .product(name: "JSON", package: "swift-json"),
                // other dependencies
            ]),
        // other targets
    ]
)
```

## building and previewing documentation 

`swift-json` is DocC-compatible. However, its documentation is a lot more useful when built with a documentation engine like [`swift-biome`](https://github.com/kelvin13/swift-biome).

### 1. gather the documentation files

`swift-json` uses the [`swift-documentation-extract`](https://github.com/swift-biome/swift-documentation-extract) plugin to gather its documentation. 

Run the `catalog` plugin command, and store its output in a JSON file.

```
swift package catalog JSON Grammar > catalog.json
```

The arguments `JSON` and `Grammar` tell `swift package catalog` to gather documentation only from the `JSON` module in this package, and the `Grammar` module in [`swift-grammar`](https://github.com/kelvin13/swift-grammar).

### 2. checkout the ecosystem

```bash
git submodule update --recursive 
```

This checks out the `.biome` submodule, which tracks [`swift-biome-index`](https://github.com/swift-biome/swift-biome-index) and contains a copy of the Swift standard library’s symbolgraph.

This repository already contains an indexfile called `swift.json`, which references the relevant modules in the ecosystem index. It’s just like the `catalog.json` file you generated in the previous step.

### 3. build [`swift-biome`](https://github.com/kelvin13/swift-biome) 

[`swift-biome`](https://github.com/kelvin13/swift-biome) is a normal SPM package. There’s lots of ways to build it. 

```bash
git clone git@github.com:kelvin13/swift-biome.git
cd swift-biome 
swift build -c release 
cd ..
```

### 4. run the `preview` server

[`swift-biome`](https://github.com/kelvin13/swift-biome) includes an executable target called **`preview`**. Pass it the two indexfiles, and it will start up a server on `localhost:8080`.

```bash
swift-biome/.build/release/preview swift.json catalog.json
```

> Note: The `swift.json` indexfile contains relative paths, so you should run `preview` from the `swift-json` repository root.

Navigate to [`http://127.0.0.1:8080/reference/swift-json`](http://127.0.0.1:8080/reference/swift-json) in a browser to view the documentation. Make sure the scheme is `http://` and not `https://`.
