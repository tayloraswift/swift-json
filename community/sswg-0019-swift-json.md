# swift-json

* Proposal: [SSWG-0019](sswg-0019-swift-json.md)
* Authors: [Kelvin Ma](https://github.com/kelvin13) ([@taylorswift](https://forums.swift.org/u/taylorswift/summary))
* Review Manager: TBD
* Status: **Released ([v0.2.1](https://github.com/kelvin13/swift-json/releases))**
* Implementation: [`swift-json`](https://github.com/kelvin13/swift-json)
* Forum Threads: [Pitch](https://forums.swift.org/t/json/54922), Discussion, Review

## Package Description

Composable, high-performance json parsing.

-  **Project name**: *SwiftJSON* 
-  **Package name**: **`swift-json`**
-  **Module name**: `JSON`
-  **Proposed Maturity Level**: [Sandbox](https://github.com/swift-server/sswg/blob/main/process/incubation.md#process-diagram)
-  **License**: [Apache 2.0](https://github.com/kelvin13/swift-json/blob/master/LICENSE)
-  **Dependencies**: [**`swift-grammar`**](https://github.com/kelvin13/swift-grammar)


## Introduction

JSON is one of the most common formats to exchange structured data as over a network. Nearly all server-side applications use JSON, which makes it an excellent candidate for library standardization.

## Motivation

Right now we’re limited to using the `JSONDecoder` vended by Foundation, either directly via a Foundation import, or indirectly [through Vapor](https://github.com/vapor/vapor/blob/main/Sources/Vapor/Content/JSONCoder%2BCustom.swift). 

Aside from requiring users to depend on Foundation, `JSONDecoder` has other disadvantages for server-side applications:

-   `JSONDecoder` is inefficient (compared to `swift-json`) because it only vends a [`Decodable`](https://swiftinit.org/reference/swift/decodable)/[`Decoder`](https://swiftinit.org/reference/swift/decoder) interface, which has well-known performance issues due to the intrinsic overhead of protocol existentials.

-   `JSONDecoder` struggles with decimal values, as it parses them all as floating point, which can lead to data corruption.

-   `JSONDecoder` does not provide a means of parsing multiple concatenated JSON messages, which precludes performant handling of high-volume, real-time streams of JSON data.

-   `JSONDecoder` has reference semantics, forces users into stateful decoding patterns, and does not fit well into Swift’s value-oriented design philosophy.

## Proposed solution

Describe your solution to the problem. Provide examples and describe
how they work. Show how your solution is better than current
workarounds: is it cleaner, safer, or more efficient?

## Detailed design

Describe the design of the solution in detail. If it's a new API, show the full API and its documentation
comments detailing what it does. The detail in this section should be
sufficient for someone who is *not* one of the authors to be able to
reasonably re-implement the feature.

## Maturity Justification

Explain why this solution should be accepted at the proposed maturity level.

## Alternatives considered

Describe alternative approaches to addressing the same problem, and
why you chose this approach instead.
