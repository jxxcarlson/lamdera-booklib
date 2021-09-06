module Data exposing
    ( Book
    , DataDict
    , DataFile
    , DataId
    , SortOrder(..)
    , blank
    , filter
    , fixUrls
    , insertDatum
    , make
    , remove
    , setupUser
    , sortBooks
    )

import Dict exposing (Dict)
import Search exposing (SearchConfig(..))
import Time


type alias Username =
    String


type alias DataId =
    String


type alias DataFile =
    { data : List Book
    , username : Username
    , creationDate : Time.Posix
    , modificationDate : Time.Posix
    , pagesRead : Int
    , pagesReadToday : Int
    , readingRate : Float
    }


type alias DataDict =
    Dict Username DataFile


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


blank currentTime =
    make "" currentTime "abc0" "" "" 0


make : Username -> Time.Posix -> String -> String -> String -> Int -> Book
make username currentTime id title author pages =
    { id = id
    , username = username
    , title = title
    , subtitle = ""
    , author = author
    , notes = ""
    , pages = pages
    , pagesRead = 0
    , rating = 0
    , public = False
    , category = ""
    , creationDate = currentTime
    , modificationDate = currentTime
    , finishDate = Nothing
    , pagesReadToday = 0
    , averageReadingRate = 0
    }


transformer { title, category, author, creationDate } =
    { targetContent = title ++ " " ++ category ++ " " ++ author, targetDate = creationDate }


sortBooks : SortOrder -> List ( Int, Book ) -> List ( Int, Book )
sortBooks sortOrder books =
    case sortOrder of
        NormalSortOrder ->
            books

        SortById ->
            List.sortBy (\b -> Tuple.second b |> .id) books

        SortByCategory ->
            List.sortBy (\b -> Tuple.second b |> .category) books

        SortByTitle ->
            List.sortBy (\b -> Tuple.second b |> .title) books

        SortByAuthor ->
            List.sortBy (\b -> Tuple.second b |> .author) books

        SortByMostRecent ->
            List.sortBy (\b -> Tuple.second b |> modificationDateToInt) books


modificationDateToInt =
    .modificationDate >> Time.posixToMillis >> (\x -> -x)


filter : String -> List Book -> List Book
filter filterString data =
    Search.search transformer NotCaseSensitive filterString data


filter1 : String -> List Book -> List Book
filter1 filterString data =
    let
        filterString_ =
            String.toLower filterString |> String.replace ":star" (String.fromChar '★')
    in
    List.filter (\datum -> String.contains filterString_ (String.toLower datum.notes)) data


setupUser : Time.Posix -> Username -> DataDict -> DataDict
setupUser currentTime username dataDict =
    let
        newDataFile =
            { data = []
            , username = username
            , creationDate = currentTime
            , modificationDate = currentTime
            , pagesRead = 0
            , pagesReadToday = 0
            , readingRate = 0
            }
    in
    Dict.insert username newDataFile dataDict


insertDatum : Username -> Book -> DataDict -> DataDict
insertDatum username datum dataDict =
    case Dict.get username dataDict of
        Nothing ->
            dataDict

        Just dataFile ->
            Dict.insert username { dataFile | data = datum :: dataFile.data } dataDict


remove : Username -> DataId -> DataDict -> DataDict
remove username id dataDict =
    case Dict.get username dataDict of
        Nothing ->
            dataDict

        Just dataFile ->
            let
                newData =
                    List.filter (\datum -> datum.id /= id) dataFile.data

                newDataFile =
                    { dataFile | data = newData }
            in
            Dict.insert username newDataFile dataDict


getUrls : String -> List String
getUrls str =
    str |> String.words |> List.filter isUrl


getLinkLabel : String -> String
getLinkLabel str =
    if String.left 7 str == "http://" then
        String.replace "http://" "" str

    else
        String.replace "https://" "" str


fixUrl : String -> String -> String
fixUrl url str =
    let
        label =
            getLinkLabel url

        link =
            " [" ++ label ++ "](" ++ url ++ ")"
    in
    String.replace url link str


fixUrls : String -> String
fixUrls str =
    let
        urls =
            getUrls str

        fixers =
            List.map fixUrl urls
    in
    List.foldl (\fixer str_ -> fixer str_) str fixers


isUrl : String -> Bool
isUrl str =
    String.left 4 str == "http"
