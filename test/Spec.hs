module Main (main) where

import Prelude hiding ((<>))
import Control.Monad (unless)
import JSON (JValue(..))
import PrettyJSON (renderJValue)
import Prettify
import qualified SimpleJSON as Simple

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

    assert "shared type" (Simple.getString (JString "hello") == Just "hello")
    assert "string mismatch" (Simple.getString JNull == Nothing)
    assert "integer truncation" (Simple.getInt (JNumber 5.8) == Just 5 && Simple.getInt (JNumber (-5.8)) == Just (-5))
    assert "integer type mismatch" (Simple.getInt (JBool True) == Nothing)
    assert "nonfinite integers" (all ((== Nothing) . Simple.getInt . JNumber) [0/0, 1/0, -1/0])
    assert "integer overflow" (Simple.getInt (JNumber 1e100) == Nothing && Simple.getInt (JNumber (-1e100)) == Nothing)
    assert "integer upper boundary" (Simple.getInt (JNumber (fromInteger (toInteger (maxBound :: Int) + 1))) == Nothing)
    assert "integer lower boundary" (Simple.getInt (JNumber (fromIntegral (minBound :: Int))) == Just minBound)
    assert "double" (Simple.getDouble (JNumber 2.5) == Just 2.5 && Simple.getDouble JNull == Nothing)
    assert "boolean" (Simple.getBool (JBool False) == Just False && Simple.getBool (JString "false") == Nothing)
    assert "object" (Simple.getObject (JObject [("x", JNull)]) == Just [("x", JNull)] && Simple.getObject (JArray []) == Nothing)
    assert "array" (Simple.getArray (JArray [JBool True]) == Just [JBool True] && Simple.getArray (JObject []) == Nothing)
    assert "null" (Simple.isNull JNull && not (Simple.isNull (JString "null")))
    putStrLn "13 accessor checks passed."
