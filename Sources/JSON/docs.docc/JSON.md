# ``/JSON``

Swift JSON is a Foundation-free JSON parser and encoder written in pure Swift. It is designed to be performant, expressive, and speedy to compile.


## Getting started

Many users only need to parse simple JSON messages, which you can do with the ``JSON.Node.init(parsing:) [3C9YH]`` initializer:

@Snippet(id: Parsing)

This produces a JSON AST ``JSON/Node``. If you import the ``JSONLegacy`` module, this type conforms to ``Decoder``, so you can decode any type that conforms to ``Decodable``.

@Snippet(id: DecodingWithCodable)

For more advanced use cases, we suggest reading the library tutorials.

## Topics

### Tutorials

-   <doc:Decoding>


### Exported modules

This module re-exports several other modules. We have invested significant effort into making these four modules as lightweight and fast to compile as possible, so we recommend importing `JSON` as a whole unless you have a measurable problem. Notably, the `JSON` module does not include the ``JSONLegacy`` module, which is designed to provide backwards compatibility with codebases that rely on ``Codable`` for JSON serialization.

-   ``JSONAST``
-   ``JSONParsing``
-   ``JSONDecoding``
-   ``JSONEncoding``


### AST

-   ``JSON.Node``
-   ``JSON.Array``
-   ``JSON.Object``
-   ``JSON.Number``

### Raw JSON

-   ``JSON``
