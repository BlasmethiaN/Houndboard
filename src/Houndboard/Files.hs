module Houndboard.Files where

import System.Directory (doesDirectoryExist, listDirectory)
import System.FilePath

getAllFiles :: FilePath -> IO [FilePath]
getAllFiles dir = do
  files <- listDirectory dir
  fmap concat $ mapM (\f -> do
    let path = dir </> f
    isDir <- doesDirectoryExist path
    if isDir
      then fmap (fmap (f </>)) $ getAllFiles path
      else pure [f]) files
