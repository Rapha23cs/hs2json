module Main (main) where

import JSON (JValue(..))
import PrettyJSON (renderJValue)

main :: IO ()
main = putStrLn (renderJValue example)

example :: JValue
example = JObject
    [ ("name", JString "Alice")
    , ("age", JNumber 30)
    , ("student", JBool True)
    , ("subjects", JArray [JString "Haskell", JString "JSON"])
    , ("profile", JObject [("bio", JString "Ol\xe1\nHaskell\t\x1f600")])
    , ("notes", JNull)
    ]
