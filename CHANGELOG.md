# Revision history for hs2json

## Unreleased

* Add `ParseJSON.parseJSON` for external JSON using the existing `JValue` type.
* Add CLI modes for inline JSON, UTF-8 files, stdin, help and the original example.
* Report invalid JSON, arguments and input errors with a failing exit code.
* Add parser and executable integration tests; document usage in `docs/CLI.md`.

* Add abstract `Doc` combinators and two-space JSON pretty printing.
* Escape control characters and Unicode, including surrogate pairs.
* Demonstrate nested JSON in the executable and add rendering regression checks.
* Add `SimpleJSON` accessors sharing the original `JSON.JValue` type.
* Reject non-finite and out-of-range integer conversions safely.
* Add bounded `Arbitrary JValue` generator for QuickCheck.
* Add property-based tests for rendering and accessors.

## 0.1.0.0 -- 2026-10-05

* First version. Released on an unsuspecting world.
