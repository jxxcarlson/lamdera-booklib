module Evergreen.V9.Data exposing (..)

import Dict
import Time


type alias Book =
    { id : String
    , username : String
    , title : String
    , subtitle : String
    , author : String
    , notes : String
    , pages : Int
    , pagesRead : Int
    , rating : Int
    , public : Bool
    , category : String
    , creationDate : Time.Posix
    , modificationDate : Time.Posix
    , finishDate : Maybe Time.Posix
    , pagesReadToday : Int
    , averageReadingRate : Float
    }


type SortOrder
    = NormalSortOrder
    | SortById
    | SortByCategory
    | SortByTitle
    | SortByAuthor
    | SortByMostRecent


type alias Username =
    String


type alias DataFile =
    { data : List Book
    , username : Username
    , creationDate : Time.Posix
    , modificationDate : Time.Posix
    }


type alias DataDict =
    Dict.Dict Username DataFile


type alias DataId =
    String
