module Main where

import Test.QuickCheck
import JSON

-- A simple dummy test to ensure QuickCheck runs
prop_jnull_eq_jnull :: Bool
prop_jnull_eq_jnull = JNull == JNull

main :: IO ()
main = do
    putStrLn "Running tests for hs2json"
    quickCheck prop_jnull_eq_jnull
