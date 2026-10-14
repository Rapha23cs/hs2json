module Main (main) where

import Prelude hiding ((<>))
import Control.Monad (unless)
import JSON (JValue(..))
import PrettyJSON (renderJValue)
import Prettify

assert :: String -> Bool -> IO ()
assert label condition = unless condition (fail label)

main :: IO ()
main = do
    assert "empty object" (renderJValue (JObject []) == "{}")
    assert "empty array" (renderJValue (JArray []) == "[]")
    assert "null" (renderJValue JNull == "null")
    assert "booleans" (map (renderJValue . JBool) [True, False] == ["true", "false"])
    assert "finite numbers" (renderJValue (JNumber (-2.5)) == "-2.5")
    assert "nonfinite" (all ((== "null") . renderJValue . JNumber) [0/0, 1/0, -1/0])
    assert "simple escapes"
        (renderJValue (JString "\"\\\b\f\n\r\t") == "\"\\\"\\\\\\b\\f\\n\\r\\t\"")
    assert "control character" (renderJValue (JString ['\0']) == "\"\\u0000\"")
    assert "unicode BMP" (renderJValue (JString ['\xe1','\x7f','\x20ac']) == "\"\\u00e1\\u007f\\u20ac\"")
    assert "unicode astral" (renderJValue (JString ['\x10000','\x1f600','\x10ffff']) == "\"\\ud800\\udc00\\ud83d\\ude00\\udbff\\udfff\"")
    assert "nested indentation and punctuation"
        (renderJValue (JObject [("items", JArray [JNumber 1, JObject []]), ("ok", JBool True)])
         == "{\n  \"items\": [\n    1.0,\n    {}\n  ],\n  \"ok\": true\n}")
    assert "escaped keys" (renderJValue (JObject [("a\nb", JNull)]) == "{\n  \"a\\nb\": null\n}")
    let doc = group (text "hello" <> nest 2 (line <> text "world"))
    assert "wide group" (pretty 80 doc == "hello world")
    assert "narrow group" (pretty 5 doc == "hello\n  world")
    assert "compact broken layout" (compact doc == "hello\n  world")
    assert "fsep without trailing whitespace" (pretty 80 (fsep [text "a", text "b"]) == "a b")
    putStrLn "16 pretty-printing checks passed."
