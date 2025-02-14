module NumberSystems where

import Data.Char


-- Перевод вплоть до 36-ичной системы счисления
-- а дальше букаф нету
toLetter :: Int -> Char
toLetter n
  | n <= 9    = chr (n + ord '0')
  | otherwise = chr (n + (ord 'A' - 10))

toNumber :: Char -> Int
toNumber c
  | c `elem` "0123456789" = ord c - ord '0'
  | otherwise             = (ord c - ord 'A') + 10


-- Из десятичной в любую систему счисления
fromBase10 :: Int -> Int -> String
fromBase10 x base 
  | x == 0 = "0"
  | otherwise
  = convert x base ""
  where
    convert y b s
      | y == 0 = s
      | otherwise
      = let q = y `div` b
            r = y `mod` b
        in convert q b (toLetter r:s)
        

-- Из любой системы счисления в десятичную
toBase10 :: String -> Int -> Int
toBase10 (c:cs) base = convert cs base (toNumber c)
  where
    convert []     _ x = x
    convert (c:cs) b x =
      convert cs b (b*x + toNumber c)


-- Для дробных чисел
epsilon :: Double
epsilon = 0.001


fromBase10D :: Double -> Double -> String
fromBase10D x base =
  let fx = (x - (fromIntegral $ floor x))
  in (fromBase10 (floor x) (floor base))
  ++ "."
  ++ (convertFract (base*fx) base)
  where
    convertFract y b
      | fy <= epsilon = [toLetter (floor y)]
      | otherwise
      = (toLetter (floor y):convertFract (b*fy) b)
        where fy = y - (fromIntegral $ floor y)


toBase10D :: String -> Double -> Double
toBase10D s base =
  let (istr, fstr) = intFract s
      i = fromIntegral $ toBase10 istr (floor base)
      f = convertFract fstr base (-1)
  in f + i where
       convertFract ""     _ _ = 0.0
       convertFract (y:fy) b k =
         (fromIntegral $ toNumber y)*(b**k) + convertFract fy b (k-1)
         
       intFract ('.':cs) = ("", cs)
       intFract (c:cs) =
         let (is, fs) = intFract cs in ((c:is), fs)
