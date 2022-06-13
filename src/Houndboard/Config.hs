module Houndboard.Config where

import Control.Monad (filterM)
import Data.Maybe (listToMaybe)
import System.Directory (doesFileExist)
import System.Environment.XDG.BaseDir (getAllConfigFiles)

projectName :: String
projectName = "houndboard"

findConfigFile :: IO (Maybe FilePath)
findConfigFile = do
  files <- filterM doesFileExist =<< getAllConfigFiles projectName "config.json"
  pure $ listToMaybe files

-- aeson
