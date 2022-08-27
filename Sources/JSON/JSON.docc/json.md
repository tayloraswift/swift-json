@import (Foundation)
@import (Grammar)

# ``JSON``

Efficiently parse and decode JSON in pure Swift.

The `JSON` module provides various rules for *parsing* JSON messages, and an expressive, 
lightweight set of tools for *decoding* parsed messages into Swift structures. Unlike the 
monolithic ``Foundation/JSONDecoder``, `JSON` vends atomized, 
composable interfaces that can be adapted and optimized for a variety of use-cases.

This module is a single-type module; its entire API lives under the ``JSON//JSON`` enumeration.

Some of the more advanced functionality in this module requires importing the ``Grammar`` 
module from ``/swift-grammar``. (It is not re-exported by default.)
