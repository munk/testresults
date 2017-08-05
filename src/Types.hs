module Types where

import Control.Exception
import Data.Typeable

type Properties = [Property]
type Timestamp = String

data Failure = Failure {
    failureType :: String
  , failureMessage :: String
  } deriving (Show)

data Error = Error {
    errorType :: String
  , errorMessage :: String
  } deriving (Show)

data Property = Property {
    propertyName :: String
  , propertyValue :: String
  } deriving (Show)

data Skipped = Skipped {
  skippedMessage :: String
  } deriving (Show)

data TestSuite = TestSuite {
    suiteName :: String
  , tests :: Integer
  , disabled :: Integer
  , errorCount :: Integer
  , failureCount :: Integer
  , skippedCount :: Integer
  , hostname :: String
  , id :: Integer
  , package :: String
  , runTime :: Integer
  , timeStamp :: Timestamp
  , properties :: [Properties]
  , testCase :: [TestCase]
  , suiteSysOut :: SystemOut
  , suiteSysErr :: SystemErr
  } deriving (Show)

data TestCase = TestCase {
    name :: String
  , assertions :: Integer
  , className :: String
  , status :: String
  , time :: Integer
  , skipped :: [Skipped]
  , errors :: [Error]
  , failures :: [Failure]
  , sysOut :: [SystemOut]
  , sysErr :: [SystemErr]
  } deriving (Show)

data TestSuites = TestSuites {
    suitesName :: String
  , totalTime :: Integer
  , totalTests :: Integer
  , totalFailures :: Integer
  , totalDisabled :: Integer
  , totalErrors :: Integer
  , suites :: [TestSuite]
  } deriving (Show)

type SystemOut = String
type SystemErr = String

data ParseError = ParseError
    deriving Typeable

instance Show ParseError where
    show ParseError = "something bad happened"

instance Exception ParseError
