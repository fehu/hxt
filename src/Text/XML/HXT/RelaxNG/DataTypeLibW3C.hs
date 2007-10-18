-- |
-- Datatype library for the W3C XML schema datatypes

module Text.XML.HXT.RelaxNG.DataTypeLibW3C
  ( w3cNS
  , w3cDatatypeLib
  , xsd_NCName
  , xsd_anyURI
  , xsd_QName
  , xsd_string
  , xsd_length
  , xsd_maxLength
  , xsd_minLength
  , xsd_pattern
  , xsd_enumeration
  )
where

import Text.XML.HXT.RelaxNG.DataTypeLibUtils  

import Network.URI
  ( isURIReference )

import Text.XML.HXT.DOM.NamespaceFilter
  ( isWellformedQualifiedName
  , isNCName
  )

  
-- ------------------------------------------------------------

-- | Namespace of the W3C XML schema datatype library
w3cNS	:: String
w3cNS	= "http://www.w3.org/2001/XMLSchema-datatypes"


xsd_NCName, xsd_anyURI, xsd_QName, xsd_string, xsd_pattern, xsd_enumeration :: String

xsd_NCName	= "NCName"
xsd_anyURI	= "anyURI"
xsd_QName	= "QName"
xsd_string	= "string"
xsd_pattern	= "pattern"
xsd_enumeration	= "enumeration"

xsd_length, xsd_maxLength, xsd_minLength :: String

xsd_length	= rng_length
xsd_maxLength	= rng_maxLength
xsd_minLength	= rng_minLength


-- | The main entry point to the W3C XML schema datatype library.
--
-- The 'DTC' constructor exports the list of supported datatypes and params.
-- It also exports the specialized functions to validate a XML instance value with
-- respect to a datatype.
w3cDatatypeLib :: DatatypeLibrary
w3cDatatypeLib = (w3cNS, DTC datatypeAllowsW3C datatypeEqualW3C w3cDatatypes)


-- | All supported datatypes of the library
w3cDatatypes :: AllowedDatatypes
w3cDatatypes = [ (xsd_NCName, stringParams)
               , (xsd_anyURI, stringParams)
               , (xsd_QName,  stringParams)
               , (xsd_string, stringParams)               
               ]


-- | List of allowed params for the string datatypes
stringParams :: AllowedParams
stringParams = [xsd_length, xsd_maxLength, xsd_minLength]


-- | Tests whether a XML instance value matches a data-pattern.
-- (see also: 'checkString')
datatypeAllowsW3C :: DatatypeAllows
datatypeAllowsW3C d params value _
    | d == xsd_NCName
	= if isNCName v && not (null v)
          then checkString d value 0 (-1) params 
	  else err1
    | d == xsd_anyURI
	= if isURIReference v2
          then checkString d value 0 (-1) params
	  else err1
    | d == xsd_QName
	= if isWellformedQualifiedName v && not (null v)
          then checkString d value 0 (-1) params
	  else err1
    | d == xsd_string
	= checkString d value 0 (-1) params
    | otherwise
	= err2
    where
    v    = normalizeWhitespace value
    v2   = escapeURI v
    err1 = Just $ errorMsgDataLibQName value d w3cNS
    err2 = Just $ errorMsgDataTypeNotAllowed d params value w3cNS

-- | Tests whether a XML instance value matches a value-pattern.
datatypeEqualW3C :: DatatypeEqual
datatypeEqualW3C d s1 _ s2 _
    | d `elem` [xsd_NCName, xsd_anyURI, xsd_QName, xsd_string]
	= if s1 == s2
	  then Nothing
	  else Just $ errorMsgEqual d s1 s2
    | otherwise
	= Just $ errorMsgDataTypeNotAllowed0 d w3cNS
