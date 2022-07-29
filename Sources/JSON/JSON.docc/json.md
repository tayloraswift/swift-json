@import (Foundation)
@import (Grammar)

# ``JSON``

Efficiently parse and decode JSON in pure Swift.

The `JSON` module provides various rules for *parsing* JSON messages, and an expressive, 
lightweight set of tools for *decoding* parsed messages into Swift structures. Unlike the 
monolithic ``Foundation/JSONDecoder``, `JSON` vends atomized, 
composable interfaces that can be adapted and optimized for a variety of use-cases.

To minimize namespace pollution, most of this module’s API lives under the ``JSON//JSON`` enumeration.

This module re-exports the ``Grammar`` module from ``/swift-grammar``.
