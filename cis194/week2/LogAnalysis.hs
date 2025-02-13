{-# OPTIONS_GHC -Wall #-}

module Main where

import Log


toMsgType :: String -> String -> (Maybe MessageType, String)
toMsgType "I" msg = (Just Info,    msg)
toMsgType "W" msg = (Just Warning, msg)
toMsgType "E" msg =
  let [(s,msg')]  = lex msg in
    (Just (Error (read s :: Int)), msg')
toMsgType _ msg   = (Nothing, msg) 



parseInt :: String -> Maybe Int
parseInt intStr = chk "" intStr
  where
    chk str "" = Just (read str :: Int)
    chk str (c:cs)
      | c `elem` "0123456789" = chk (str++[c]) cs
      | otherwise             = Nothing

parseMessage :: String -> LogMessage
parseMessage msg =
  let [(msgTypeStr, msg')] = lex msg
      (msgTypeMaybe,msg'') = toMsgType msgTypeStr msg'
  in case msgTypeMaybe of
    Nothing      -> Unknown msg
    Just msgType ->
      let [(timeStampStr,msgRest)] = lex msg''
          timeStamp = parseInt timeStampStr
      in case timeStamp of
        Nothing -> Unknown msg
        Just ts ->
          LogMessage msgType ts (strip msgRest)
          where 
            strip (c:cs)
              | c == ' '  = strip cs
              | otherwise = (c:cs)
            strip "" = ""


splitLines :: String -> [String]
splitLines text = getLines "" text
  where
    getLines line ""        = [line]
    getLines line ('\n':cs) = (line:getLines "" cs)
    getLines line (c:cs)    = getLines (line++[c]) cs

parse :: String -> [LogMessage]
parse text =
  let lns = splitLines text
  in parseLines lns
  where
    parseLines []          = []
    parseLines (line:rest) = (parseMessage line:parseLines rest)


sortMessages :: [LogMessage] -> MessageTree
sortMessages []               = Leaf
sortMessages (Unknown _:msgs) = sortMessages msgs
sortMessages (rootMsg:msgs)   =
  foldl sort (Node Leaf rootMsg Leaf) msgs
  where
    sort tree (Unknown _) = tree
    sort (Node l' v'@(LogMessage _ ts1' _) r') w'@(LogMessage _ ts2' _)
      | ts2' < ts1' = Node (sort l' w') v' r'
      | otherwise   = Node l' v' (sort r' w')
    sort Leaf lm = Node Leaf lm Leaf


main = do
  f <- readFile "sample.log"
  print (sortMessages $ parse f)
