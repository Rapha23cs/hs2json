module Main (main) where

import Control.Exception (bracket)
import Control.Monad (forM_, unless)
import Data.Either (isLeft)
import Data.List (isInfixOf)
import GHC.IO.Encoding (setLocaleEncoding)
import System.Directory (getTemporaryDirectory, removeFile)
import System.Exit (ExitCode(..))
import System.IO
    ( IOMode(WriteMode), hClose, hIsClosed, hPutStr, hSetEncoding
    , openTempFile, utf8, withFile
    )
import System.Process (readProcessWithExitCode)

import ParseJSON (parseJSON)
import PrettyJSON (renderJValue)
import SimpleJSON (JValue(..))

assert :: String -> Bool -> IO ()
assert name passed = unless passed (fail name)

main :: IO ()
main = do
    setLocaleEncoding utf8
    let valid =
            [ ("null", JNull)
            , ("\xfeff null", JNull)
            , (" true \r\n", JBool True)
            , ("false", JBool False)
            , ("-12.5e+2", JNumber (-1250))
            , ("0", JNumber 0)
            , ("-0", JNumber (-0))
            , ("1E-2", JNumber 0.01)
            , ("[]", JArray [])
            , ("{ }", JObject [])
            , ("[1,true,null]", JArray [JNumber 1, JBool True, JNull])
            , ("{\"x\":1,\"x\":2}", JObject [("x", JNumber 1), ("x", JNumber 2)])
            , ("\"\\\"\\\\\\/\\b\\f\\n\\r\\t\"", JString "\"\\/\b\f\n\r\t")
            , ("\"\\u0000\\u00e1\\ud83d\\ude00\"", JString "\0\xe1\x1f600")
            , ("\"Ol\xe1 \x1f600\"", JString "Ol\xe1 \x1f600")
            , (" { \"a\" : [ { \"b\" : \"c\" } ] } ",
               JObject [("a", JArray [JObject [("b", JString "c")]])])
            ]
    forM_ valid $ \(input, expected) -> do
        assert ("parse valid input: " ++ show input) (parseJSON input == Right expected)
        assert ("parse/render round trip: " ++ show input)
            (parseJSON (renderJValue expected) == Right expected)

    let invalid =
            [ "", " ", "null true", "true!", "NaN", "Infinity"
            , "+1", "01", "-01", ".5", "1.", "1e", "1e+", "1e9999"
            , "[1,]", "{\"x\":1,}", "{x:1}", "[1 2]", "{\"x\" 1}"
            , "\"unterminated", "\"raw\ncontrol\"", "\"bad\\q\"", "\"\\u123\""
            , "\"\\ud800\"", "\"\\udc00\"", "\"\\ud800\\u0041\""
            , "[\xa0null]"
            , "[\xfeffnull]", "null\xfeff"
            ]
    forM_ invalid $ \input ->
        assert ("reject invalid input: " ++ show input) (isLeft (parseJSON input))
    putStrLn "Parser: valid values, round trips and invalid inputs passed."

    expectOutput "inline JSON" ["--json", "{\"x\":1}"] "" "{\n  \"x\": 1.0\n}\n"
    expectOutput "explicit stdin" ["-"] "[true,null]" "[\n  true,\n  null\n]\n"
    expectOutput "redirected stdin" [] "false" "false\n"
    expectOutput "Unicode stdin" ["-"] "\"Ol\xe1 \x1f600\"" "\"Ol\\u00e1 \\ud83d\\ude00\"\n"
    expectFailure "malformed JSON" ["--json", "[1,]"] ""
    expectFailure "empty stdin" ["-"] ""
    expectFailure "trailing input" ["--json", "null true"] ""
    expectFailure "unknown option" ["--unknown"] ""
    expectFailure "missing argument" ["--file"] ""
    expectFailure "multiple sources" ["--json", "null", "-"] ""
    (helpCode, helpText, helpErrors) <- run ["--help"] ""
    assert "help" (helpCode == ExitSuccess && "Uso:" `isInfixOf` helpText && null helpErrors)
    (exampleCode, exampleText, exampleErrors) <- run ["--example"] ""
    assert "original example"
        (exampleCode == ExitSuccess && null exampleErrors && case parseJSON exampleText of
            Right (JObject fields) -> lookup "name" fields == Just (JString "Alice")
            _ -> False)

    tempDirectory <- getTemporaryDirectory
    bracket (openTempFile tempDirectory "hs2json cli test.json")
        (\(path, handle) -> do
            closed <- hIsClosed handle
            unless closed (hClose handle)
            removeFile path) $ \(path, handle) -> do
            hSetEncoding handle utf8
            hPutStr handle "{\"nome\":\"Jo\xe3o\"}"
            hClose handle
            expectOutput "UTF-8 file with spaces in its path" ["--file", path] ""
                "{\n  \"nome\": \"Jo\\u00e3o\"\n}\n"
            withFile path WriteMode $ \fileHandle -> do
                hSetEncoding fileHandle utf8
                hPutStr fileHandle "\xfeff[false]"
            expectOutput "UTF-8 file with BOM" ["--file", path] "" "[\n  false\n]\n"
            withFile path WriteMode $ \fileHandle -> hPutStr fileHandle "[1,]"
            expectFailure "malformed JSON file" ["--file", path] ""
    bracket (openTempFile tempDirectory "hs2json-missing.json")
        (\_ -> pure ()) $ \(path, handle) -> do
            hClose handle
            removeFile path
            expectFailure "missing file" ["--file", path] ""
    putStrLn "CLI: arguments, stdin, UTF-8 files, help, example and error codes passed."

run :: [String] -> String -> IO (ExitCode, String, String)
run args input = do
    (code, out, err) <- readProcessWithExitCode "hs2json" args input
    pure (code, filter (/= '\r') out, filter (/= '\r') err)

expectOutput :: String -> [String] -> String -> String -> IO ()
expectOutput name args input expected = do
    (code, out, err) <- run args input
    assert name (code == ExitSuccess && out == expected && null err)

expectFailure :: String -> [String] -> String -> IO ()
expectFailure name args input = do
    (code, out, err) <- run args input
    assert name (code /= ExitSuccess && null out && not (null err))
