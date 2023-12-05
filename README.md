<div align="center">

***`json`***<br>`0.6.0`

[![ci build status](https://github.com/tayloraswift/swift-json/actions/workflows/build.yml/badge.svg)](https://github.com/tayloraswift/swift-json/actions/workflows/build.yml)
[![ci devices build status](https://github.com/tayloraswift/swift-json/actions/workflows/build-devices.yml/badge.svg)](https://github.com/tayloraswift/swift-json/actions/workflows/build-devices.yml)
[![ci benchmarks status](https://github.com/tayloraswift/swift-json/actions/workflows/benchmarks.yml/badge.svg)](https://github.com/tayloraswift/swift-json/actions/workflows/benchmarks.yml)

[![swift package index versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftayloraswift%2Fswift-json%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/tayloraswift/swift-json)
[![swift package index platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftayloraswift%2Fswift-json%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/tayloraswift/swift-json)

</div>

`swift-json` is a pure-Swift JSON parsing library designed for high-performance, high-throughput server-side applications. When compared using the test data [`captured.json`](Benchmarks/), `swift-json` is nearly 7 times faster than `Foundation.JSONDecoder` ([see benchmark source code](Benchmarks/Sources/GeneralDecoding)). This library is powered by [`swift-grammar`](https://github.com/tayloraswift/swift-grammar)!

**Importing this module will expose the following top-level symbol(s)**:

* `enum JSON`

## example usage

The `JSON` module in `swift-json` enables you to express JSON parsing tasks as **constructive parsers**. This makes the `JSON` module very flexible without requiring much configuration from users who simply want to parse a JSON message from a remote peer.

To parse a complete JSON message, use its [`init(parsing:)`](https://swiftinit.org/reference/swift-json/json/json.init%28parsing:%29) initializer, or for more flexibility, the [`JSON.Rule<Location>.Root`](https://swiftinit.org/reference/swift-json/json/json/rule/root) parsing rule:

> [`DecodingWithCodable.swift`](Snippets/DecodingWithCodable.swift)

```swift
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
```

```text
$ swift run DecodingWithCodable
Response(success: true, value: Decimal(units: 1, places: 1))
```

The rule is called “[`Root`](https://swiftinit.org/reference/swift-json/json/json/rule/root)” because it will match only complete JSON messages (objects or arrays).
Like most `swift-grammar`-based [parsers](https://swiftinit.org/reference/swift-grammar/grammar/parsingrule), [`JSON.Rule`](https://swiftinit.org/reference/swift-json/json/json/rule) is generic over its input, which means you can parse directly from some [`Collection`](https://swiftinit.org/reference/swift/collection) of [`UInt8`](https://swiftinit.org/reference/swift/uint8).

`swift-json`’s constructive parsing engine also allows you to get diagnostics for invalid JSON messages:

> [`ParsingDiagnostics.swift`](Snippets/ParsingDiagnostics.swift)

```swift
import Grammar
import JSON

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
    let annotated:String = error.annotate(source: invalid,
        renderer: String.init(_:),
        newline: \.isNewline)
    print(annotated)
}
```
```text
$ swift run ParsingDiagnostics
UnexpectedValueError: (no description available)
{"success":true,value:0.1}
                ^
note: while parsing pattern 'DoubleQuote'
{"success":true,value:0.1}
                ^
note: while parsing pattern 'StringLiteral'
{"success":true,value:0.1}
                ^
note: while parsing pattern '(Pad<Comma, Whitespace>, Item)'
{"success":true,value:0.1}
               ^~
note: while parsing pattern 'Object'
{"success":true,value:0.1}
^~~~~~~~~~~~~~~~~
note: while parsing pattern 'Root'
{"success":true,value:0.1}
^~~~~~~~~~~~~~~~~
```

You can be more selective about the form of the JSON you expect to receive by using one of the library’s subrules:


*   [`Null`](https://swiftinit.org/reference/swift-json/json/json/rule/null)
*   [`True`](https://swiftinit.org/reference/swift-json/json/json/rule/true)
*   [`False`](https://swiftinit.org/reference/swift-json/json/json/rule/false)
*   [`NumberLiteral`](https://swiftinit.org/reference/swift-json/json/json/rule/numberliteral)
*   [`StringLiteral`](https://swiftinit.org/reference/swift-json/json/json/rule/stringliteral)
*   [`Object`](https://swiftinit.org/reference/swift-json/json/json/rule/object)
*   [`Array`](https://swiftinit.org/reference/swift-json/json/json/rule/array)


The [`JSON`](https://swiftinit.org/reference/swift-json/json) module supports parsing arbitrary JSON fragments using the [`JSON.Rule<Location>.Value`](https://swiftinit.org/reference/swift-json/json/json/rule/value) rule.

The nature of constructive parsing also means it is straightforward to parse *multiple* concatenated JSON messages, as is commonly encountered when interfacing with streaming JSON APIs.

## adding `swift-json` as a dependency

To use `swift-json` in a project, add the following to your `Package.swift` file:

```swift
let package = Package(
    ...
    dependencies:
    [
        // other dependencies
        .package(url: "https://github.com/tayloraswift/swift-json", from: "0.5.0"),
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

`swift-json` is DocC-compatible. However, its documentation is a lot more useful when built with a documentation engine like [`swift-biome`](https://github.com/tayloraswift/swift-biome).

### 1. gather the documentation files

`swift-json` uses the [`swift-package-catalog`](https://github.com/tayloraswift/swift-package-catalog) plugin to gather its documentation.

Run the `catalog` plugin command, and store its output in a file named `Package.catalog`.

```
$ swift package catalog > Package.catalog
```

The catalog file must be named `Package.catalog`; Biome parses it (and the `Package.resolved` file generated by the Swift Package Manager) in order to find `swift-json`’s symbolgraphs and DocC archives.

### 2. build [`swift-biome`](https://github.com/tayloraswift/swift-biome)

[`swift-biome`](https://github.com/tayloraswift/swift-biome) is a normal SPM package. There’s lots of ways to build it.

```bash
$ git clone git@github.com:tayloraswift/swift-biome.git
$ git submodule update --init --recursive

$ cd swift-biome
$ swift build -c release
$ cd ..
```

Don’t forget the `git submodule update`!

### 3. run the `preview` server

[`swift-biome`](https://github.com/tayloraswift/swift-biome) includes an executable target called **`preview`**. Pass it the path to the `swift-json` repository (in this example, `..`), and it will start up a server on `localhost:8080`.

```bash
$ cd swift-biome
$ .build/release/preview --swift 5.6.2 ..
```

The `--swift 5.6.2` option specifies the version of the standard library that the Biome compiler should link against.

> Note: if you run the `preview` tool from outside the `swift-biome` repository, you will need to specify the path to the [`resources`](https://github.com/swift-biome/swift-biome-resources) (sub)module. For example, if you did not `cd` into `swift-biome`, you would have to add the option `--resources swift-biome/resources`.

Navigate to [`http://127.0.0.1:8080/reference/swift-json`](http://127.0.0.1:8080/reference/swift-json) in a browser to view the documentation. Make sure the scheme is `http://` and not `https://`.
