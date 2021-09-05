module Frontend.Codec exposing (decodeData, decodeSpecialData, encodeData)

import Data exposing (Book)
import Json.Decode as D
import Json.Decode.Pipeline as DP
import Json.Encode as E
import Time exposing(Month(..))
import DateTime exposing(DateTime)

decodeData : String -> Result D.Error (List Book)
decodeData str =
    D.decodeString dataDecoder str

decodeSpecialData : String -> String -> Result D.Error (List Book)
decodeSpecialData username str =
    D.decodeString (specialDataDecoder username) str


dataDecoder : D.Decoder (List Book)
dataDecoder =
    D.list datumDecoder

specialDataDecoder : String -> D.Decoder (List Book)
specialDataDecoder  username =
    D.list (specialDatumDecoder |> D.map (transformBook2 username))

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

transformBook2 : String -> Book2 -> Book
transformBook2 username book2 =
      {  id = username ++ String.fromInt book2.id
        , username = username
        , title = book2.title
        , subtitle = book2.subtitle
        , author = book2.author
        , notes = book2.notes
        , pages = book2.pages
        , pagesRead = book2.pagesRead
        , rating = book2.rating
        , public = book2.public
        , category = book2.category
        , creationDate = book2.startDateString |> stringToPosix
        , modificationDate = book2.startDateString |> stringToPosix
        , finishDate = Just book2.finishDateString |> Maybe.map stringToPosix
        , pagesReadToday = book2.pagesReadToday
        , averageReadingRate = book2.averageReadingRate |> toFloat
        }



type alias Book2 =
    { author : String
    , averageReadingRate : Int
    , category : String
    , finishDateString : String
    , id : Int
    , notes : String
    , pages : Int
    , pagesRead : Int
    , pagesReadToday : Int
    , public : Bool
    , rating : Int
    , startDateString : String
    , subtitle : String
    , title : String
    , userId : Int
    }


specialDatumDecoder : D.Decoder Book2
specialDatumDecoder =
    let
        fieldSet0 =
            D.map8 Book2
                (D.field "author" D.string)
                (D.field "averageReadingRate" D.int)
                (D.field "category" D.string)
                (D.field "finishDateString" D.string)
                (D.field "id" D.int)
                (D.field "notes" D.string)
                (D.field "pages" D.int)
                (D.field "pagesRead" D.int)
    in
    D.map8 (<|)
        fieldSet0
        (D.field "pagesReadToday" D.int)
        (D.field "public" D.bool)
        (D.field "rating" D.int)
        (D.field "startDateString" D.string)
        (D.field "subtitle" D.string)
        (D.field "title" D.string)
        (D.field "userId" D.int)






stringToPosix : String -> Time.Posix
stringToPosix str  =
    stringDateToDateTime str |> Maybe.map DateTime.toPosix  |> Maybe.withDefault (Time.millisToPosix 0)

stringDateToDateTime : String -> Maybe DateTime
stringDateToDateTime str =
    case String.split "/" str of
        (m::d::y::[]) -> tripleToDateTime m d y
        _ -> Nothing

tripleToDateTime : String -> String -> String -> Maybe DateTime
tripleToDateTime m__ d__ y__ =
  let
      m_ = String.toInt m__
      d_ = String.toInt d__
      y_ = String.toInt y__
  in
  case (m_, d_, y_) of
      (Just m, Just d, Just y) ->
        case intToMonth m of
            Nothing -> Nothing
            Just mm ->
                DateTime.fromRawParts { day = d, month = mm, year = y} { hours = 0, minutes = 0, seconds = 0, milliseconds = 0}
      _ -> Nothing

intToMonth : Int -> Maybe Month
intToMonth k =
    case k of
        1 ->
            Just Jan

        2 ->
            Just Feb

        3 ->
            Just Mar

        4 ->
            Just Apr

        5 ->
            Just May

        6 ->
            Just Jun

        7 ->
            Just Jul

        8 ->
            Just Aug

        9 ->
            Just Sep

        10 ->
            Just Oct

        11 ->
            Just Nov

        12 ->
            Just Dec

        _ ->
            Nothing



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
