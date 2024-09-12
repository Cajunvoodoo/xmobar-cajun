module Attic where

import Config
import Control.Concurrent
import Control.Concurrent.Async (async)
import Control.Concurrent.STM
import qualified Data.Char as Char
import qualified Text.Printf as Printf
import Xmobar

data CombinedMonitor a b = CombinedMonitor a b (String -> String -> String)

instance (Show a, Show b) => Show (CombinedMonitor a b) where
  show (CombinedMonitor a b _) = "Alt (" ++ show a ++ ") (" ++ show b ++ ")"

instance (Read a, Read b) => Read (CombinedMonitor a b) where
  readsPrec _ = undefined

instance (Exec a, Exec b) => Exec (CombinedMonitor a b) where
  alias (CombinedMonitor a b _) = alias a ++ "_" ++ alias b
  rate (CombinedMonitor a b _) = min (rate a) (rate b)
  start (CombinedMonitor a b comb) cb =
    startMonitors a b (\s t -> cb $ comb s t)

startMonitors a b cmb = do
  sta <- newTVarIO ""
  stb <- newTVarIO ""
  _ <- async $ start a (atomically . writeTVar sta)
  _ <- async $ start b (atomically . writeTVar stb)
  go sta stb
 where
  go sta' stb' = do
    s <- readTVarIO sta'
    t <- readTVarIO stb'
    cmb s t
    tenthSeconds $ min (rate b) (rate a)
    go sta' stb'

guardedMonitor a p = CombinedMonitor (PipeReader p (alias a ++ "_g")) a f
 where
  f s t = if null s || head s == '0' then "" else t

altMonitor a b = CombinedMonitor a b (\s t -> if null s then t else s)
concatMonitor sep a b = CombinedMonitor a b (\s t -> s ++ sep ++ t)
toggleMonitor path a = altMonitor (guardedMonitor a path)

-- compMPD p = concatMonitor " " mpd (autoMPD "150" (pIsLight p))
-- alt x p = altMonitor (mpris p x 165) (compMPD p)

-- config cl p =
--   if cl == "mpd"
--   then mpdConfig p
--   else Bottom.config [Run (alt cl p)] "|mpris2_mpd_autompd|" p
