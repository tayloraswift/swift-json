<p align="center">
  <strong><em><code>grammar</code></em></strong><br><small>server-side swift submodule</small>
</p>

This is a non-resilient Swift submodule. It should be imported as a Git submodule, not an SPM package. 

**This submodule will add the following top-level symbols to your namespace**:

* `enum Grammar`
* `protocol TraceableError`
* `protocol TraceableErrorRoot`

In addition, it adds symbols to the following standard-library namespaces:

* `extension Swift.Unicode` (adds the `Latin1` namespace)
* `extension Swift.Unicode.ASCII` (adds various ASCII definitions)
* `extension Swift.Character` (adds various character definitions)

All declarations are `internal`.
