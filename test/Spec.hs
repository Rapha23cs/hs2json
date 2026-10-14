module Main (main) where

import Prelude hiding ((<>))
import Control.Monad (unless)
import Test.QuickCheck
import JSON (JValue(..))
import PrettyJSON (renderJValue)
import Prettify
import qualified SimpleJSON as Simple

assert :: String -> Bool -> IO ()
assert label condition = unless condition (fail label)

-- Gerador limitado para JValue, controlando o tamanho para evitar explosão recursiva
instance Arbitrary JValue where
    arbitrary = sized genJValue
      where
        genJValue 0 = oneof
            [ JString <$> arbitrary
            , JNumber <$> arbitrary
            , JBool   <$> arbitrary
            , pure JNull
            ]
        genJValue n = frequency
            [ (2, JString <$> arbitrary)
            , (2, JNumber <$> arbitrary)
            , (2, JBool   <$> arbitrary)
            , (1, pure JNull)
            , (1, JArray  <$> resize (n `div` 2) (listOf (genJValue (n `div` 2))))
            , (1, JObject <$> resize (n `div` 2) (listOf (genPair (n `div` 2))))
            ]
        genPair n = do
            k <- arbitrary
            v <- genJValue n
            return (k, v)

-- Propriedades com QuickCheck

-- 1. Qualquer JSON renderizado produz uma string não vazia
prop_renderNotEmpty :: JValue -> Bool
prop_renderNotEmpty v = not (null (renderJValue v))

-- 2. Delimitadores externos de objetos e arrays são sempre preservados
prop_renderDelimiters :: JValue -> Bool
prop_renderDelimiters v = case v of
    JObject _ -> head out == '{' && last out == '}'
    JArray _  -> head out == '[' && last out == ']'
    _         -> True
  where
    out = renderJValue v

-- 3. isNull é verdadeiro se e somente se o valor for JNull
prop_isNullConsistent :: JValue -> Bool
prop_isNullConsistent v = Simple.isNull v == (v == JNull)

-- 4. getString recupera a string armazenada em JString
prop_getStringRoundtrip :: String -> Bool
prop_getStringRoundtrip s = Simple.getString (JString s) == Just s

-- 5. getBool recupera o booleano armazenado em JBool
prop_getBoolRoundtrip :: Bool -> Bool
prop_getBoolRoundtrip b = Simple.getBool (JBool b) == Just b

-- 6. getArray recupera a lista original de elementos
prop_getArrayRoundtrip :: [JValue] -> Bool
prop_getArrayRoundtrip xs = Simple.getArray (JArray xs) == Just xs

-- 7. getObject recupera a lista original de pares chave-valor
prop_getObjectRoundtrip :: [(String, JValue)] -> Bool
prop_getObjectRoundtrip ps = Simple.getObject (JObject ps) == Just ps

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

    putStrLn "\n--- QuickCheck Properties ---"
    quickCheck prop_renderNotEmpty
    quickCheck prop_renderDelimiters
    quickCheck prop_isNullConsistent
    quickCheck prop_getStringRoundtrip
    quickCheck prop_getBoolRoundtrip
    quickCheck prop_getArrayRoundtrip
    quickCheck prop_getObjectRoundtrip
