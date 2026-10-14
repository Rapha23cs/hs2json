-- | Small document library, based on the course tutorial.
module Prettify
    ( Doc, empty, char, text, double, line, (<>), hcat, fsep, (</>)
    , punctuate, group, softline, nest, compact, pretty
    ) where

import Prelude hiding ((<>))

-- Constructors stay private so callers use the document combinators.
data Doc = Empty | Char Char | Text String | Line
         | Concat Doc Doc | Union Doc Doc | Nest Int Doc
         deriving (Eq, Show)

empty :: Doc
empty = Empty

char :: Char -> Doc
char = Char

text :: String -> Doc
text "" = Empty
text s = Text s

double :: Double -> Doc
double = text . show

line :: Doc
line = Line

infixr 6 <>
(<>) :: Doc -> Doc -> Doc
Empty <> b = b
a <> Empty = a
a <> b = Concat a b

hcat :: [Doc] -> Doc
hcat = foldr (<>) empty

fsep :: [Doc] -> Doc
fsep [] = empty
fsep docs = foldr1 (</>) docs

infixr 5 </>
(</>) :: Doc -> Doc -> Doc
a </> b = a <> softline <> b

punctuate :: Doc -> [Doc] -> [Doc]
punctuate _ [] = []
punctuate _ [d] = [d]
punctuate p (d:ds) = (d <> p) : punctuate p ds

group :: Doc -> Doc
group d = Union (flatten d) d

softline :: Doc
softline = group line

-- | Indent subsequent lines; the current line is unaffected.
nest :: Int -> Doc -> Doc
nest amount = Nest (max 0 amount)

flatten :: Doc -> Doc
flatten Line = Char ' '
flatten (Concat a b) = Concat (flatten a) (flatten b)
flatten (Union a _) = flatten a
flatten (Nest amount d) = Nest amount (flatten d)
flatten d = d

-- | Render the broken layout, as in the tutorial's compact renderer.
compact :: Doc -> String
compact d = transform [(0, d)]
  where
    transform [] = ""
    transform ((indent, current):rest) = case current of
        Empty -> transform rest
        Char c -> c : transform rest
        Text s -> s ++ transform rest
        Line -> '\n' : replicate indent ' ' ++ transform rest
        Concat a b -> transform ((indent, a):(indent, b):rest)
        Union _ b -> transform ((indent, b):rest)
        Nest amount child -> transform ((indent + amount, child):rest)

-- | Prefer a flattened group when it fits the requested line width.
-- Long tokens are kept intact even when they exceed the width.
pretty :: Int -> Doc -> String
pretty width d = best 0 [(0, d)]
  where
    best _ [] = ""
    best column ((indent, current):rest) = case current of
        Empty -> best column rest
        Char c -> c : best (column + 1) rest
        Text s -> s ++ best (column + length s) rest
        Line -> '\n' : replicate indent ' ' ++ best indent rest
        Concat a b -> best column ((indent, a):(indent, b):rest)
        Union a b ->
            let flat = best column ((indent, a):rest)
            in if fits (max 0 width - column) flat
               then flat
               else best column ((indent, b):rest)
        Nest amount child -> best column ((indent + amount, child):rest)

fits :: Int -> String -> Bool
fits remaining _ | remaining < 0 = False
fits _ "" = True
fits _ ('\n':_) = True
fits remaining (_:rest) = fits (remaining - 1) rest
