-- | Safe accessors and the course's public interface.
-- Reuse JSON's type so both module names remain compatible.
module SimpleJSON
    ( JValue(..), getString, getInt, getDouble, getBool, getObject, getArray, isNull
    ) where

import JSON (JValue(..))

getString :: JValue -> Maybe String
getString (JString s) = Just s
getString _ = Nothing

-- | Truncate toward zero, as in the tutorial. Reject non-finite numbers
-- and results outside Int's range rather than raising an error or overflowing.
getInt :: JValue -> Maybe Int
getInt (JNumber n)
    | isNaN n || isInfinite n = Nothing
    | integer < toInteger (minBound :: Int) = Nothing
    | integer > toInteger (maxBound :: Int) = Nothing
    | otherwise = Just (fromInteger integer)
  where
    integer = truncate n :: Integer
getInt _ = Nothing

getDouble :: JValue -> Maybe Double
getDouble (JNumber n) = Just n
getDouble _ = Nothing

getBool :: JValue -> Maybe Bool
getBool (JBool b) = Just b
getBool _ = Nothing

getObject :: JValue -> Maybe [(String, JValue)]
getObject (JObject fields) = Just fields
getObject _ = Nothing

getArray :: JValue -> Maybe [JValue]
getArray (JArray values) = Just values
getArray _ = Nothing

isNull :: JValue -> Bool
isNull JNull = True
isNull _ = False
