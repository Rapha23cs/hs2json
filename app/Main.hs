module Main where

import JSON

main :: IO ()
main = do
    putStrLn "hs2json: JSON Pretty-printing library"
    print $ JObject [("name", JString "Alice"), ("age", JNumber 30)]
