# ``/JSON``

Swift JSON is a Foundation-free JSON parser and encoder written in pure Swift. It is designed to be performant, expressive, and speedy to compile.

This module re-exports several other modules:

## Exported modules

-   ``JSONAST``
-   ``JSONParsing``
-   ``JSONDecoding``
-   ``JSONEncoding``

We have invested significant effort into making these four modules as lightweight and fast to compile as possible, so we recommend importing `JSON` as a whole unless you have a measurable problem. Notably, the `JSON` module does not include the ``JSONLegacy`` module, which is designed to provide backwards compatibility with codebases that rely on ``Codable`` for JSON serialization.


## Getting started

You can parse a JSON message to an AST node using the ``JSON.Node.init(parsing:) [3C9YH]`` initializer:

@Snippet(id: Parsing)

You can decode structures that conform to ``Codable`` by importing the ``JSONLegacy`` module.

@Snippet(id: DecodingWithCodable)


## Decoding objects

Due to inherent limitations of ``Codable``, you may gain a considerable performance boost by using the more-specialized ``JSONDecodable`` and ``JSONEncodable`` protocols.

Here’s an example of decoding a JSON object.

@Snippet(id: DecodingObjects)


## Decoding arrays

And here’s an example of decoding a JSON array.

@Snippet(id: DecodingArrays)


## Topics

### AST

-   ``JSON.Node``
-   ``JSON.Array``
-   ``JSON.Object``
-   ``JSON.Number``

### Raw JSON

-   ``JSON``
