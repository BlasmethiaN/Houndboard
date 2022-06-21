module Houndboard.Options (optionsParser) where

import Options.Applicative
import Data.Text (Text)
import Houndboard.Config
import Houndboard.Files
import Lens.Micro.Platform ((^.))
import qualified Data.Text as T

type Options = Maybe Text

optionsParser :: ParserInfo Options
optionsParser =
  info
    (optionsP <**> helper)
    ( fullDesc
        <> progDesc "Your favorite program for sounds"
        <> header "houndboard - a soundboard for your favorite sounds"
    )

optionsP :: Parser Options
optionsP = 
  Just <$> strArgument (metavar "FILEPATH" <> completer (listIOCompleter filePathCompleter))
  <|> pure Nothing

filePathCompleter :: IO [String]
filePathCompleter = do
  config <- getConfig
  getAllFiles $ (T.unpack $ config ^. baseDir)
