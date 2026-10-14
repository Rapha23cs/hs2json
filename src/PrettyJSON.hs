module PrettyJSON (renderJValue) where

import Prelude hiding ((<>))
import Data.Bits ((.&.), shiftR)
import Data.Char (ord)
import Numeric (showHex)

import SimpleJSON (JValue(..))
import Prettify (Doc, (<>), char, double, hcat, line, nest, pretty, punctuate, text)

-- | Render JSON using two-space indentation. Non-finite numbers become null,
-- since JSON cannot represent NaN or infinity.
renderJValue :: JValue -> String
renderJValue = pretty 80 . valueDoc

valueDoc :: JValue -> Doc
valueDoc (JString s) = string s
valueDoc (JNumber n)
    | isNaN n || isInfinite n = text "null"
    | otherwise = double n
valueDoc (JBool True) = text "true"
valueDoc (JBool False) = text "false"
valueDoc JNull = text "null"
valueDoc (JArray values) = series '[' ']' valueDoc values
valueDoc (JObject fields) = series '{' '}' field fields
  where
    field (key, value) = string key <> text ": " <> valueDoc value

series :: Char -> Char -> (a -> Doc) -> [a] -> Doc
series open close _ [] = char open <> char close
series open close item values =
    char open <> nest 2 (line <> separated) <> line <> char close
  where
    separated = foldr1 (\a b -> a <> line <> b)
                (punctuate (char ',') (map item values))

string :: String -> Doc
string s = char '"' <> hcat (map oneChar s) <> char '"'

oneChar :: Char -> Doc
oneChar c = case lookup c simpleEscapes of
    Just escaped -> text escaped
    Nothing
        | c < ' ' || c > '~' -> hexEscape c
        | otherwise -> char c

simpleEscapes :: [(Char, String)]
simpleEscapes = zipWith (\c code -> (c, ['\\', code]))
               "\b\n\f\r\t\\\"" "bnfrt\\\""

hexEscape :: Char -> Doc
hexEscape c
    | code < 0x10000 = smallHex code
    | otherwise = smallHex (0xd800 + (offset `shiftR` 10))
                  <> smallHex (0xdc00 + (offset .&. 0x3ff))
  where
    code = ord c
    offset = code - 0x10000

smallHex :: Int -> Doc
smallHex code = text ("\\u" ++ replicate (4 - length digits) '0' ++ digits)
  where
    digits = showHex code ""
