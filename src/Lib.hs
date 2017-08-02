module Lib
    ( someFunc
    ) where

import Text.XML.Light
import Text.XML.Light.Lexer
import Data.Maybe
import Types
import Control.Exception

readXml filepath = do
  xmlContent <- readFile filepath
  return (parseXML xmlContent)

parseTestCase content =
  (TestCase
    (attr name)
    (attrInt tests)
    (attr className) "" 0 [] [] [] [] [])
  where
    element = head (onlyElems (parseXML content))
    name = QName "name" Nothing Nothing
    className = QName "classname" Nothing Nothing
    tests = QName "assertions" Nothing Nothing
    attrInt = (\key -> (read (fromMaybe "0" (findAttr key element))) :: Integer)
    attr = (\key -> (fromMaybe "" (findAttr key element)))

parseFailure :: XmlSource t => t -> Failure
parseFailure xmlContent = parse Failure xmlContent "failure"

parseError :: XmlSource t => t -> Error
parseError xmlContent = parse Error xmlContent "error"

parseProperty :: XmlSource t => t -> Property
parseProperty content =
  Property (attr name) (attr value)
  where
    element = head (onlyElems (parseXML content))
    name = QName "name" Nothing Nothing
    value = QName "value" Nothing Nothing
    attr = (\key -> (fromMaybe "" (findAttr key element)))

parseSkipped :: XmlSource t => t -> Skipped
parseSkipped content = Skipped (attr message)
  where
    element = head (onlyElems (parseXML content))
    message = QName "message" Nothing Nothing
    attr = (\key -> (fromMaybe "" (findAttr key element)))

parse :: XmlSource t => ([Char] -> [Char] -> t1) -> t -> String -> t1
parse t content qname = -- TODO: handle exeption if qName is wrong...
  let em = head (onlyElems (parseXML content))
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
