-- | Parse external JSON into the existing representation, preserving field order.
module ParseJSON (parseJSON) where

import Data.Char (chr, isHexDigit, ord)
import Numeric (readHex)
import Text.ParserCombinators.ReadP
    ( ReadP, (<++), between, char, count, eof, many, munch, munch1
    , option, pfail, readP_to_S, satisfy, sepBy, skipMany, string
    )
import Text.Read (readMaybe)

import SimpleJSON (JValue(..))

-- | Consume exactly one JSON value and optional JSON whitespace.
-- Numbers use the project's finite Double representation. Unpaired Unicode
-- surrogates are rejected instead of producing non-interoperable strings.
parseJSON :: String -> Either String JValue
parseJSON input = case readP_to_S (spaces *> value <* spaces <* eof) withoutBOM of
    (result, ""):_ -> Right result
    _ -> Left "JSON invalido: verifique a sintaxe, escapes Unicode e numeros finitos no intervalo de Double."
  where
    -- Some Windows editors add a UTF-8 BOM. Accept it only at the start.
    withoutBOM = case input of
        '\xfeff':rest -> rest
        _ -> input

spaces :: ReadP ()
spaces = skipMany (satisfy (`elem` " \t\r\n"))

token :: ReadP a -> ReadP a
token parser = parser <* spaces

value :: ReadP JValue
value = token $
        (JString <$> jsonString)
    <++ (JNumber <$> jsonNumber)
    <++ (JBool True <$ string "true")
    <++ (JBool False <$ string "false")
    <++ (JNull <$ string "null")
    <++ (JArray <$> between (token (char '[')) (char ']')
                    (value `sepBy` token (char ',')))
    <++ (JObject <$> between (token (char '{')) (char '}')
                     (field `sepBy` token (char ',')))
  where
    field = do
        key <- token jsonString
        _ <- token (char ':')
        item <- value
        pure (key, item)

jsonString :: ReadP String
jsonString = between (char '"') (char '"') (many stringChar)

stringChar :: ReadP Char
stringChar = satisfy isLiteral <++ (char '\\' *> escaped)
  where
    isLiteral c = c >= ' ' && c /= '"' && c /= '\\' && not (isSurrogate (ord c))
    escaped = do
        code <- satisfy (`elem` "\"\\/bfnrtu")
        case code of
            'u' -> unicodeChar
            _ -> case lookup code (zip "\"\\/bfnrt" "\"\\/\b\f\n\r\t") of
                Just c -> pure c
                Nothing -> pfail

unicodeChar :: ReadP Char
unicodeChar = do
    first <- hexCode
    if first >= 0xd800 && first <= 0xdbff
        then do
            _ <- string "\\u"
            second <- hexCode
            if second >= 0xdc00 && second <= 0xdfff
                then pure (chr (0x10000 + (first - 0xd800) * 0x400 + second - 0xdc00))
                else pfail
        else if isSurrogate first then pfail else pure (chr first)

isSurrogate :: Int -> Bool
isSurrogate n = n >= 0xd800 && n <= 0xdfff

hexCode :: ReadP Int
hexCode = do
    digits <- count 4 (satisfy isHexDigit)
    case readHex digits of
        [(n, "")] -> pure n
        _ -> pfail

jsonNumber :: ReadP Double
jsonNumber = do
    sign <- option "" (string "-")
    integer <- string "0" <++ ((:) <$> satisfy (\c -> c >= '1' && c <= '9') <*> munch isDigit)
    fraction <- option "" ((:) <$> char '.' <*> munch1 isDigit)
    exponentPart <- option "" $ do
        marker <- satisfy (`elem` "eE")
        exponentSign <- option "" ((:[]) <$> satisfy (`elem` "+-"))
        digits <- munch1 isDigit
        pure (marker : exponentSign ++ digits)
    case readMaybe (sign ++ integer ++ fraction ++ exponentPart) of
        Just n | not (isNaN n || isInfinite n) -> pure n
        _ -> pfail
  where
    isDigit c = c >= '0' && c <= '9'
