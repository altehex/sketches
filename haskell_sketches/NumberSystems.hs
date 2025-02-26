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
  in    (fromBase10 (floor x) (floor base))
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


add :: String -> String -> Int -> String
add ('-':x) y       base = sub y x base
add x       ('-':y) base = sub x y base
add ('-':x) ('-':y) base = ('-' : add x y base)
add x       y       base =
  let (rx:rxs) = rev x
      (ry:rys) = rev y
      s        = rx <+> ry
  in rev $ radd s rxs rys base
  where
    a <+> b = toNumber a + toNumber b

    radd s' [] [] base
      | s' < base = [toLetter s']
      | otherwise = (toLetter (s' - base) : "1")

    radd s' x'@(rx':rxs') [] base
      | s' < base = (toLetter s'          : x')
      | otherwise = (toLetter (s' - base) : radd (rx' <+> '1') rxs' [] base)

    radd s' [] y'@(ry':rys') base
      | s' < base = (toLetter s'          : y')
      | otherwise = (toLetter (s' - base) : radd (ry' <+> '1') rys' [] base)
    
    radd s' (rx':rxs') (ry':rys') base
      | s' < base = (toLetter s'          : radd (rx' <+> ry')     rxs' rys' base)
      | otherwise = (toLetter (s' - base) : radd (rx' <+> ry' + 1) rxs' rys' base)
    
    rev [x']    = [x']
    rev (x':xs) = (rev xs)++[x']


sub :: String -> String -> Int -> String
sub ('-':x) ('-':y) base = sub y x base
sub ('-':x) y       base = ('-' : add x y base)
sub x       ('-':y) base = add x y base
sub x       y       base =
  let (rx:rxs) = rev x
      (ry:rys) = rev y
  in stripZeros $ rev $ if (toBase10 x base) > (toBase10 y base) then
                          rsub (rx <-> ry) rxs rys base
                        else
                          (rsub (ry <-> rx) rys rxs base) ++ ['-']
  where
    a <-> b = toNumber a - toNumber b

    rsub d' [] [] base = [toLetter d']

    rsub d' x'@(rx':rxs') [] base
      | d' >= 0   = (toLetter d'          : x')
      | otherwise = (toLetter (base + d') : rsub (rx' <-> '1') rxs' [] base)

    rsub d' (rx':rxs') (ry':rys') base
      | d' >= 0   = (toLetter d'          : rsub (rx' <-> ry')     rxs' rys' base)
      | otherwise = (toLetter (base + d') : rsub (rx' <-> ry' - 1) rxs' rys' base)
    
    rev [x']    = [x']
    rev (x':xs) = (rev xs)++[x']

    stripZeros ('0':as) = stripZeros as
    stripZeros as       = as
