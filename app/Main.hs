module Main where

import Houndboard.Config

main :: IO ()
main = do
  print =<< findConfigFile
