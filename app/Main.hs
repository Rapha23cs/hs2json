module Main (main) where

import Control.Exception (evaluate)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO
    ( Handle, IOMode(ReadMode), hGetContents, hIsTerminalDevice, hPutStrLn
    , hSetEncoding, stderr, stdin, stdout, utf8, withFile
    )
import System.IO.Error (tryIOError)

import ParseJSON (parseJSON)
import SimpleJSON (JValue(..))
import PrettyJSON (renderJValue)

main :: IO ()
main = do
    hSetEncoding stdout utf8
    hSetEncoding stderr utf8
    args <- getArgs
    case args of
        ["--help"] -> putStr usage
        ["--example"] -> printExample
        ["--json", input] -> formatJSON input
        ["--file", path] -> readInput (withFile path ReadMode readUTF8)
        ["-"] -> readInput (readUTF8 stdin)
        [] -> do
            interactive <- hIsTerminalDevice stdin
            if interactive then printExample else readInput (readUTF8 stdin)
        _ -> die ("Argumentos invalidos.\n" ++ usage)

printExample :: IO ()
printExample = putStrLn (renderJValue example)

readUTF8 :: Handle -> IO String
readUTF8 handle = do
    hSetEncoding handle utf8
    input <- hGetContents handle
    -- Force lazy input while its handle is open and IO errors can be caught.
    _ <- evaluate (length input)
    pure input

readInput :: IO String -> IO ()
readInput source = do
    result <- tryIOError source
    case result of
        Left err -> die ("Nao foi possivel ler a entrada: " ++ show err)
        Right input -> formatJSON input

formatJSON :: String -> IO ()
formatJSON input = case parseJSON input of
    Left message -> die message
    Right parsed -> putStrLn (renderJValue parsed)

die :: String -> IO a
die message = hPutStrLn stderr message >> exitFailure

usage :: String
usage = unlines
    [ "Uso: hs2json [--json TEXTO | --file ARQUIVO | - | --example | --help]"
    , "  --json TEXTO     Formata um valor JSON recebido como argumento."
    , "  --file ARQUIVO   Le um arquivo JSON em UTF-8."
    , "  -                Le JSON da entrada padrao ate o fim (EOF)."
    , "  --example        Mostra a demonstracao original."
    , "  --help           Mostra esta ajuda."
    , "Sem argumentos: mostra o exemplo no terminal ou le a entrada redirecionada."
    , "Numeros usam Double; valores fora de seu intervalo finito sao rejeitados."
    ]

example :: JValue
example = JObject
    [ ("name", JString "Alice")
    , ("age", JNumber 30)
    , ("student", JBool True)
    , ("subjects", JArray [JString "Haskell", JString "JSON"])
    , ("profile", JObject [("bio", JString "Ol\xe1\nHaskell\t\x1f600")])
    , ("notes", JNull)
    ]
