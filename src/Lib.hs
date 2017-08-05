{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( someFunc
    ) where

import Text.XML.Light
import Text.XML.Light.Lexer
import Data.Maybe
import Types
import Control.Exception

sampleXmlPath = "/Users/jdowns/src/learn-haskell/testResults/sample.xml"

--readXml :: FilePath -> IO [TestSuites]
readXml filepath = do
  raw <- readFile filepath
  let content = parseXML raw
      elements = mapMaybe getElement content
      testSuites = filter (\e -> qNameLens e == "testsuites") elements
  --return testSuites
  return $ map parseTestSuites testSuites

findXmlAttr qname = findAttr (QName qname Nothing Nothing)
readJust probably = read (fromJust probably)

getElement :: Content -> Maybe Element
getElement (Elem e) = Just e
getElement _ = Nothing

qNameLens :: Element -> String
qNameLens element = qName (elName element)

parseTestSuites :: Element -> TestSuites
parseTestSuites suites =
  TestSuites suiteNames totalTime totalTests totalFailures totalDisabled totalErrors testSuites
  where
    suiteNames = fromJust $ (findXmlAttr "name" suites)
    totalTime = readJust (findXmlAttr "time" suites) :: Integer
    totalTests = readJust (findXmlAttr "tests" suites) :: Integer
    totalFailures = readJust (findXmlAttr "failures" suites) :: Integer
    totalDisabled = readJust (findXmlAttr "disabled" suites) :: Integer
    totalErrors = readJust (findXmlAttr "errors" suites) :: Integer
    testSuites = map parseTestSuite (filter (\x -> qNameLens x == "testsuite") (elChildren suites))
    
parseTestSuite :: Element -> TestSuite
parseTestSuite suite =
  (TestSuite
    "name"
    tests
    disabled
    errorCount
    failureCount
    skippedCount
    hostName
    suiteId
    packageName
    runTime
    timeStamp
    properties
    testCases
    sysOut
    sysErr)
  where
    attr = (\key -> (fromMaybe "" (findXmlAttr key suite)))
    attrInt = (\key -> (read (fromMaybe "0" (findXmlAttr key suite)) :: Integer))
    tests = attrInt "tests"
    disabled = attrInt "disabled"
    errorCount = attrInt "errors"
    failureCount = attrInt "failures"
    skippedCount = attrInt "disabled"
    hostName = attr "hostname"
    suiteId = attrInt "id"
    packageName = attr "package"
    runTime = attrInt "time"
    timeStamp = attr "timestamp"
    properties = []
    testCases = []
    sysOut = ""
    sysErr = ""


parseTestCase :: [Content] -> TestCase
parseTestCase content =
  (TestCase
    (attr name)
    (attrInt tests)
    (attr className) "" 0 [] [] [] [] [])
  where
    element = head (onlyElems content)
    name = QName "name" Nothing Nothing
    className = QName "classname" Nothing Nothing
    tests = QName "assertions" Nothing Nothing
    attrInt = (\key -> (read (fromMaybe "0" (findAttr key element))) :: Integer)
    attr = (\key -> (fromMaybe "" (findAttr key element)))

parseFailure :: [Content] -> Failure
parseFailure xmlContent = parse Failure xmlContent "failure"

parseError :: [Content] -> Error
parseError xmlContent = parse Error xmlContent "error"

parseProperty :: [Content] -> Property
parseProperty content =
  Property (attr name) (attr value)
  where
    element = head (onlyElems content)
    name = QName "name" Nothing Nothing
    value = QName "value" Nothing Nothing
    attr = (\key -> (fromMaybe "" (findAttr key element)))

parseSkipped :: [Content] -> Skipped
parseSkipped content = Skipped (attr message)
  where
    element = head (onlyElems content)
    message = QName "message" Nothing Nothing
    attr = (\key -> (fromMaybe "" (findAttr key element)))

parse :: ([Char] -> [Char] -> t) -> [Content] -> String -> t
parse t content qname =
  let em = head (onlyElems content)
      mq = QName "message" Nothing Nothing
      tq = QName "type" Nothing Nothing
      attr = (\name -> (fromMaybe "" (findAttr name em)))
  in
    if (qName $ elName em) == qname
    then
      t (attr mq) (attr tq)
    else
      throw ParseError


someFunc :: IO ()
someFunc = putStrLn "someFunc"
