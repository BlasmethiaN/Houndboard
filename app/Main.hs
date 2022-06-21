module Main where

import Houndboard.Config
import Houndboard.Options
import qualified SDL.Mixer as Mix
import qualified SDL
import System.FilePath
import Control.Concurrent (threadDelay)
import Control.Monad (when)
import qualified Data.Text as T
import Lens.Micro.Platform ((^.))
import Options.Applicative (execParser)

main :: IO ()
main = do
  SDL.initialize [SDL.InitAudio]
  options <- execParser optionsParser
  case options of
    Nothing -> putStrLn "<<insert TUI>>"
    Just fileName -> do
      config <- getConfig
      Mix.withAudio Mix.defaultAudio 4096 $ do
        music <- Mix.load $ (T.unpack $ config ^. baseDir) </> T.unpack fileName
        Mix.playMusic 1 music
        wait

wait :: IO ()
wait = do
  threadDelay 100000
  stillPlaying <- Mix.playingMusic
  when stillPlaying wait
