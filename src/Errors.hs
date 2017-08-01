module Errors where


data ParseError = ParseError
    deriving Typeable

instance Show ParseError where
    show ParseError = "something bad happened"

instance Exception ParseError
