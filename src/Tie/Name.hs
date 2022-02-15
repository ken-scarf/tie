{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}

module Tie.Name
  ( PackageName,
    ApiName,
    Name,
    fromText,
    cabalFileName,
    toDataTypeName,
    toOneOfDataTypeName,
    toOneOfConstructorName,
    toFunctionName,
    toConstructorName,
    toFieldName,
    toJsonFieldName,
    toParamName,
    toParamBinder,
    toApiTypeName,
    toSchemaHaskellFileName,
    toSchemaHaskellModuleName,
    toOperationHaskellFileName,
    toOperationHaskellModuleName,
    toResponseHaskellFileName,
    toResponseHaskellModuleName,
    apiHaskellModuleName,
    apiHaskellFileName,
    responseHaskellModuleName,
    responseHaskellFileName,
    inlineObjectTypeName,
    inlineVariantTypeName,
    toApiResponseTypeName,
    toApiResponseConstructorName,
    toApiDefaultResponseConstructorName,
    toApiMemberName,
  )
where

import Data.Char (toLower, toUpper)
import qualified Data.Text as Text
import qualified Prettyprinter as PP

-- | Name of the API to generate code for
type ApiName = Text

-- | Cabal package name
type PackageName = Text

-- | Names identify things in the OpenApi universe. Name's are coming directly
-- from the OpenApi spec.
newtype Name = Name {unName :: Text}
  deriving (IsString, Eq, Ord, Show, Hashable)

fromText :: Text -> Name
fromText = Name

cabalFileName :: PackageName -> FilePath
cabalFileName packageName =
  Text.unpack packageName <> ".cabal"

apiHaskellModuleName :: ApiName -> Text
apiHaskellModuleName apiName =
  apiName <> ".Api"

apiHaskellFileName :: ApiName -> FilePath
apiHaskellFileName apiName =
  Text.unpack apiName <> "/Api.hs"

responseHaskellModuleName :: ApiName -> Text
responseHaskellModuleName apiName =
  apiName <> ".Response"

responseHaskellFileName :: ApiName -> FilePath
responseHaskellFileName apiName =
  Text.unpack apiName <> "/Response.hs"

toSchemaHaskellModuleName :: ApiName -> Name -> Text
toSchemaHaskellModuleName apiName (Name name) =
  Text.pack $ Text.unpack apiName <> ".Schemas." <> capitalizeFirstLetter (Text.unpack name)

toSchemaHaskellFileName :: ApiName -> Name -> FilePath
toSchemaHaskellFileName apiName (Name name) =
  Text.unpack apiName <> "/Schemas/" <> capitalizeFirstLetter (Text.unpack name) <> ".hs"

toOperationHaskellModuleName :: ApiName -> Name -> Text
toOperationHaskellModuleName apiName (Name name) =
  Text.pack $ Text.unpack apiName <> ".Api." <> capitalizeFirstLetter (Text.unpack name)

toOperationHaskellFileName :: ApiName -> Name -> FilePath
toOperationHaskellFileName apiName (Name name) =
  Text.unpack apiName <> "/Api/" <> capitalizeFirstLetter (Text.unpack name) <> ".hs"

toResponseHaskellModuleName :: ApiName -> Name -> Text
toResponseHaskellModuleName apiName (Name name) =
  Text.pack $ Text.unpack apiName <> ".Response." <> capitalizeFirstLetter (Text.unpack name)

toResponseHaskellFileName :: ApiName -> Name -> FilePath
toResponseHaskellFileName apiName (Name name) =
  Text.unpack apiName <> "/Response/" <> capitalizeFirstLetter (Text.unpack name) <> ".hs"

toApiTypeName :: Name -> PP.Doc ann
toApiTypeName =
  toDataTypeName

toJsonFieldName :: Name -> PP.Doc ann
toJsonFieldName = PP.pretty . unName

toDataTypeName :: Name -> PP.Doc ann
toDataTypeName =
  PP.pretty . Text.pack . capitalizeFirstLetter . Text.unpack . unName

toOneOfDataTypeName :: Name -> PP.Doc ann
toOneOfDataTypeName =
  PP.pretty . Text.pack . capitalizeFirstLetter . Text.unpack . unName

toOneOfConstructorName :: Name -> Name -> PP.Doc ann
toOneOfConstructorName (Name oneOfType) (Name variant) =
  PP.pretty $
    Text.pack $
      escapeKeyword $
        capitalizeFirstLetter (Text.unpack oneOfType)
          <> capitalizeFirstLetter (Text.unpack variant)

toConstructorName :: Name -> PP.Doc ann
toConstructorName = toDataTypeName

toFunctionName :: Name -> PP.Doc ann
toFunctionName =
  PP.pretty . Text.pack . escapeKeyword . lowerFirstLetter . Text.unpack . unName

toFieldName :: Name -> PP.Doc ann
toFieldName =
  PP.pretty . Text.pack . escapeKeyword . lowerFirstLetter . Text.unpack . unName

toParamName :: Name -> PP.Doc ann
toParamName =
  PP.pretty . unName

toParamBinder :: Name -> PP.Doc ann
toParamBinder =
  PP.pretty . Text.pack . escapeKeyword . lowerFirstLetter . Text.unpack . unName

toApiMemberName :: Name -> PP.Doc ann
toApiMemberName =
  PP.pretty . Text.pack . escapeKeyword . lowerFirstLetter . Text.unpack . unName

toApiResponseTypeName :: Name -> PP.Doc ann
toApiResponseTypeName =
  PP.pretty . Text.pack . escapeKeyword . (<> "Response") . capitalizeFirstLetter . Text.unpack . unName

toApiResponseConstructorName :: Name -> Int -> PP.Doc ann
toApiResponseConstructorName name statusCode =
  PP.pretty . Text.pack . escapeKeyword . (<> show statusCode) . (<> "Response") . capitalizeFirstLetter . Text.unpack . unName $ name

toApiDefaultResponseConstructorName :: Name -> PP.Doc ann
toApiDefaultResponseConstructorName name =
  PP.pretty . Text.pack . escapeKeyword . (<> "DefaultResponse") . capitalizeFirstLetter . Text.unpack . unName $ name

-- | Constructs a name for an object defined inline. Based on the containing data
-- type as well as the field name.
inlineObjectTypeName :: Name -> Name -> Name
inlineObjectTypeName (Name parentType) (Name fieldName) =
  Name $
    Text.pack $
      escapeKeyword $
        capitalizeFirstLetter (Text.unpack parentType)
          <> capitalizeFirstLetter (Text.unpack fieldName)

-- | Construct a name for an inline type in a oneOf.
inlineVariantTypeName :: Name -> Int -> Name
inlineVariantTypeName (Name parentType) ith =
  Name $
    Text.pack $
      escapeKeyword $
        capitalizeFirstLetter (Text.unpack parentType) <> "OneOf" <> show ith

lowerFirstLetter :: String -> String
lowerFirstLetter [] = []
lowerFirstLetter (x : xs) = toLower x : xs

capitalizeFirstLetter :: String -> String
capitalizeFirstLetter [] = []
capitalizeFirstLetter (x : xs) = toUpper x : xs

escapeKeyword :: String -> String
escapeKeyword input = case input of
  "type" -> "type'"
  "class" -> "class'"
  "where" -> "where'"
  "case" -> "case'"
  "of" -> "of'"
  "data" -> "data'"
  "import" -> "import'"
  "qualified" -> "qualified'"
  "as" -> "as'"
  "instance" -> "instance'"
  "module" -> "module'"
  _ -> input