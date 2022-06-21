{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Houndboard.Config where

import Control.Monad (filterM)
import Data.Maybe (fromMaybe, listToMaybe)
import System.Directory (doesFileExist, getHomeDirectory)
import System.Environment.XDG.BaseDir (getAllConfigFiles)
import Data.Aeson
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Generics
import Control.Monad.Trans.Maybe
import Control.Monad.IO.Class
import System.Exit
import qualified Lens.Micro.Platform as L

data Config = Config {
  _baseDir :: Text
} deriving (Show, Eq, Generic)

$(L.makeLenses ''Config)

dropN :: Int -> Options -> Options
dropN n opts = opts { fieldLabelModifier = drop n }

instance FromJSON Config where
    parseJSON = genericParseJSON $ dropN 1 defaultOptions

instance ToJSON Config where
    toJSON = genericToJSON $ dropN 1 defaultOptions

defaultConfig :: Config
defaultConfig = Config {
  _baseDir = "~/.local/share/houndboard"
}

projectName :: String
projectName = "houndboard"

findConfigFile :: IO (Maybe FilePath)
findConfigFile = fmap listToMaybe $ filterM doesFileExist =<< getAllConfigFiles projectName "config.json"

substHome :: Text -> Text -> Text
substHome homeDir path = if T.isPrefixOf "~" path
  then T.replace "~" homeDir path
  else path

getConfig :: IO Config
getConfig = do
  home <- T.pack <$> getHomeDirectory
  fmap (L.over baseDir (substHome home) . fromMaybe defaultConfig) $
    runMaybeT $ do
      file <- MaybeT findConfigFile
      decoded <- liftIO $ decodeFileStrict' file
      case decoded of
        Nothing -> liftIO $ die "Invalid config"
        Just c -> pure c
