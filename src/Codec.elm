module Codec exposing (decodeData, encodeData)

import Data exposing (Book)
import Json.Decode as D
import Json.Decode.Pipeline as DP
import Json.Encode as E
import Time


decodeData : String -> Result D.Error (List Book)
decodeData str =
    D.decodeString dataDecoder str


dataDecoder : D.Decoder (List Book)
dataDecoder =
    D.list datumDecoder


datumDecoder : D.Decoder Book
datumDecoder =
    D.succeed Book
        |> DP.required "id" D.string
        |> DP.required "username" D.string
        |> DP.required "title" D.string
        |> DP.required "subtitle" D.string
        |> DP.required "author" D.string
        |> DP.required "notes" D.string
        |> DP.required "pages" D.int
        |> DP.required "pagesRead" D.int
        |> DP.required "rating" D.int
        |> DP.required "public" D.bool
        |> DP.required "category" D.string
        |> DP.required "creationDate" (D.int |> D.map Time.millisToPosix)
        |> DP.required "modificationDate" (D.int |> D.map Time.millisToPosix)
        |> DP.required "finishDate" (D.int |> D.map mapToMaybeTimePosix)
        |> DP.required "pagesReadToday" D.int
        |> DP.required "averageReadingRate" D.float


mapToMaybeTimePosix : Int -> Maybe Time.Posix
mapToMaybeTimePosix k =
    if k <= 0 then
        Nothing

    else
        Just (Time.millisToPosix k)


encodeData : List Book -> String
encodeData data =
    E.encode 3 (dataEncoder data)


dataEncoder : List Book -> E.Value
dataEncoder data =
    E.list datumEncoder data


datumEncoder : Book -> E.Value
datumEncoder datum =
    E.object
        [ ( "id", E.string datum.id )
        , ( "username", E.string datum.username )
        , ( "title", E.string datum.title )
        , ( "subtitle", E.string datum.subtitle )
        , ( "author", E.string datum.author )
        , ( "notes", E.string datum.notes )
        , ( "pages", E.int datum.pages )
        , ( "pagesRead", E.int datum.pagesRead )
        , ( "rating", E.int datum.rating )
        , ( "public", E.bool datum.public )
        , ( "category", E.string datum.category )
        , ( "creationDate", E.int (Time.posixToMillis datum.creationDate) )
        , ( "modificationDate", E.int (Time.posixToMillis datum.creationDate) )
        , ( "finishDate", E.int (transformFinishDate datum.finishDate) )
        , ( "pagesReadToday", E.int datum.pagesReadToday )
        , ( "averageReadingRate", E.float datum.averageReadingRate )
        ]


transformFinishDate : Maybe Time.Posix -> Int
transformFinishDate posix =
    case posix of
        Nothing ->
            0

        Just p ->
            Time.posixToMillis p
