# Decoding JSON

Projects that use a lot of JSON often benefit from a protocol-oriented code organization strategy. This tutorial will show you how to decode schema using the ``JSONDecodable`` protocol hierarchy.


## Why a parallel protocol hierarchy?

There are two main reasons why ``JSONDecodable`` (and ``JSONEncodable``) are separate from ``Codable``. The first reason is performance. Due to inherent limitations of ``Codable``, many users gain a considerable performance boost by using the more-specialized JSON protocols.

Another reason is code organization. You may find protocol conformances to be a natural place to attach decoding logic to, and the ``JSONDecodable`` hierarchy helps you answer the all-important question of “where should my code live?”.


## Topics

### Decodability protocols

Most decodable types have a particular type of AST ``JSON/Node`` that they are decoded from. Although the ``JSONDecodable.init(json:) [requirement]`` requirement is the ultimate witness that will be called by the decoder, it is often more convenient to decode from a ``String`` or a typed ``JSON.ObjectDecoder``.

-   ``JSONDecodable``
-   ``JSONStringDecodable``
-   ``JSONObjectDecodable``


### Decoding strings

The ``JSONStringDecodable`` protocol is a bridge that allows string-convertible types to opt into an automatic string-based ``JSONDecodable`` conformance. If your type already conforms to ``LosslessStringConvertible``, you do not need to write any code other than the conformance itself.


### Decoding objects

Distinguishing between missing, null, and present values is a common problem when decoding JSON objects. Generally, you access some ``JSON/TraceableDecoder`` through a (non-throwing) subscript, and then catch errors when calling one of its `decode` methods. This allows you to express varying expectations using optional chaining.

| Syntax | Meaning |
| --- | --- |
| `try $0[k]?.decode()` | The field is optional, and throw an error if it is present but not decodable. |
| `try $0[k].decode()` | The field is required, and throw an error if it is missing or not decodable. |

The field decoder types hold a temporary copy of the key which they are decoding, which allows them to display a helpful stack trace if decoding fails.

-   ``JSON.FieldDecoder``
-   ``JSON.OptionalDecoder``


#### Worked example

Here’s an example of decoding a JSON object.

@Snippet(id: DecodingObjects)


### Decoding arrays

Decoding arrays involves a similar syntax to decoding objects, but there is no concept of an optional field. Instead, you generally check preconditions on an``JSON/ArrayShape`` before proceeding with decoding.

#### Worked example

Here’s an example of decoding a JSON array.

@Snippet(id: DecodingArrays)
