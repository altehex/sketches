module GaussianMethod where


solveSystem :: [[Float]] -> [Float] -> [Float]
solveSystem [[a_nn]] [b_n] = [ b_n/a_nn ]
solveSystem ((a_11:a_1s):as) (b_1:bs) =
  let a' = buildA as a_11 a_1s
      b' = buildB bs b_1 a_11 as
      xs = solveSystem a' b'
      x1 = (b_1 - mulSum a_1s xs)/a_11
  in (x1:xs)
  where
    mulSum []       []       = 0
    mulSum (ak:aks) (xk:xks) = ak*xk + mulSum aks xks 

    buildA []               _    _    = []
    buildA ((a_21:a_2s):as) a_11 a_1s =
      ( buildARow a_2s a_21 a_11 a_1s
      : buildA as a_11 a_1s )
          where
            buildARow []          _    _    []          = []
            buildARow (a_22:a_2s) a_21 a_11 (a_12:a_1s) =
              (a_22 - a_12*a_21/a_11 : buildARow a_2s a_21 a_11 a_1s)

    buildB []       _   _    []               = []
    buildB (b_2:bs) b_1 a_11 ((a_21:_):as) =
      (b_2 - a_21*b_1/a_11 : buildB bs b_1 a_11 as)


systemFmt :: [[Float]] -> [Float] -> [Float] -> String
systemFmt []       _ []       = ""
systemFmt (a_1:as) x (b_1:bs) =
  (fmtLine a_1 x b_1)++"\n"++(systemFmt as x bs)
  where
    fmtLine []        []       _   = ""
    fmtLine (a_11:as) (x_1:xs) b_1 =
         (show a_11)++"*"++(show x_1)
      ++ (addRest as xs)++" = "++(show b_1)
      where
        addRest []        []       = ""
        addRest (a_21:as) (x_2:xs) =
             " + "++(show a_21)++"*"++(show x_2)++(addRest as xs)


solveFmt :: [[Float]] -> [Float] -> String
solveFmt a b =
  let x = solveSystem a b
  in systemFmt a x b


