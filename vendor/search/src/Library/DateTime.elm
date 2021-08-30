module Library.DateTime exposing ( changeTime, midnight
    , dateFromString
    , elapsedTimeAsMinutes
    , elapsedTimeAsSeconds
    , elapsedTimeAsString
    , millisecondsFromDateString
    , yearFromPosix
    , zonedDateString
    , rawDateFromString
    , zonedDateTime
    , zonedTimeString
    )

import Calendar exposing (Date)
import Clock
import DateTime exposing (DateTime)
import Library.HMParser as HMParser
import List.Extra
import Maybe.Extra
import Time exposing (Month(..))


midnight : Clock.RawTime
midnight =  { hours = 23
    , minutes =59
    , seconds =59
    , milliseconds = 0
    }



type alias Seconds =
    Int


{-|

    Let t2 = changeTime "00:01" "00:02: t1
    Then t2 is a Posix time one minute greater than t1.

-}
changeTime : String -> String -> Time.Posix -> Time.Posix
changeTime t1 t2 posix =
    case ( HMParser.getMinutes t1, HMParser.getMinutes t2 ) of
        ( Nothing, _ ) ->
            posix

        ( _, Nothing ) ->
            posix

        ( Just m1, Just m2 ) ->
            let
                millis : Int
                millis =
                    Time.posixToMillis posix

                newMillis : Int
                newMillis =
                    millis + 60000 * (m2 - m1)
            in
            Time.millisToPosix newMillis


yearFromPosix : Time.Posix -> Int
yearFromPosix posix =
    posix |> Calendar.fromPosix |> Calendar.getYear


millisecondsFromDateString : String -> Int
millisecondsFromDateString str =
    str
        |> posixFromDateString
        |> Maybe.map Time.posixToMillis
        |> Maybe.withDefault 0


posixFromDateString : String -> Maybe Time.Posix
posixFromDateString str =
    str |> dateTimeFromDateString |> Maybe.map DateTime.toPosix


dateTimeFromDateString : String -> Maybe DateTime
dateTimeFromDateString str =
    case rawDateFromString str of
        Nothing ->
            Nothing

        Just rawDate ->
            DateTime.fromRawParts rawDate { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }


rawDateFromString : String -> Maybe { day : Int, month : Month, year : Int }
rawDateFromString str =
    case intsFromString str of
        [ monthInt, dayInt, yearInt ] ->
            case monthFromInt monthInt of
                Nothing ->
                    Nothing

                Just month ->
                    Just { day = dayInt, month = month, year = yearInt }

        _ ->
            Nothing


dateFromString : String -> Maybe Date
dateFromString str =
    case intsFromString str of
        [ monthInt, dayInt, yearInt ] ->
            case monthFromInt monthInt of
                Nothing ->
                    Nothing

                Just month ->
                    Calendar.fromRawParts { day = dayInt, month = month, year = yearInt }

        _ ->
            Nothing


intsFromString : String -> List Int
intsFromString str =
    let
        parts =
            String.split "/" str
    in
    case [ List.Extra.getAt 0 parts, List.Extra.getAt 1 parts, List.Extra.getAt 2 parts ] of
        [ Just day, Just month, Just year ] ->
            List.map String.toInt [ day, month, year ] |> Maybe.Extra.values

        _ ->
            []


elapsedTimeAsString : Time.Posix -> Time.Posix -> String
elapsedTimeAsString a b =
    let
        elapsedInSeconds =
            elapsedTimeAsSeconds a b

        elapsedInMinutes =
            elapsedInSeconds // 60

        minutes =
            modBy 60 elapsedInMinutes

        hours =
            (elapsedInMinutes - minutes) // 60
    in
    String.padLeft 2 '0' (String.fromInt hours) ++ ":" ++ String.padLeft 2 '0' (String.fromInt minutes)


elapsedTimeAsSeconds : Time.Posix -> Time.Posix -> Seconds
elapsedTimeAsSeconds a b =
    let
        aa =
            Time.posixToMillis a

        bb =
            Time.posixToMillis b
    in
    (bb - aa) // 1000


elapsedTimeAsMinutes : Time.Posix -> Time.Posix -> Float
elapsedTimeAsMinutes a b =
    toFloat (elapsedTimeAsSeconds a b) / 60.0


zonedDateString : Time.Zone -> Time.Posix -> String
zonedDateString zone time =
    let
        date =
            zonedDateTime zone time |> DateTime.getDate
    in
    monthFromDate date ++ " " ++ dayFromDate date ++ " " ++ yearFromDate date


zonedTimeString : Time.Zone -> Time.Posix -> String
zonedTimeString zone time_ =
    let
        time =
            zonedDateTime zone time_ |> DateTime.getTime
    in
    hoursFromClockTime time ++ ":" ++ minutesFromClockTime time


zonedDateTime : Time.Zone -> Time.Posix -> DateTime
zonedDateTime zone time_ =
    let
        offset : Int
        offset =
            DateTime.getTimezoneOffset zone time_

        timeInMilliseconds =
            Time.posixToMillis time_

        newTime =
            Time.millisToPosix (timeInMilliseconds + offset)
    in
    DateTime.fromPosix newTime



-- CONVERTERS


hoursFromClockTime : Clock.Time -> String
hoursFromClockTime time =
    Clock.getHours time |> String.fromInt |> String.padLeft 2 '0'


minutesFromClockTime : Clock.Time -> String
minutesFromClockTime time =
    Clock.getMinutes time |> String.fromInt |> String.padLeft 2 '0'


yearFromDate : Date -> String
yearFromDate date =
    Calendar.getYear date |> String.fromInt


dayFromDate : Date -> String
dayFromDate date =
    Calendar.getDay date |> String.fromInt


monthFromDate : Date -> String
monthFromDate date =
    Calendar.getMonth date |> stringFromMonth


monthFromInt : Int -> Maybe Month
monthFromInt k =
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


stringFromMonth : Time.Month -> String
stringFromMonth month =
    case month of
        Jan ->
            "Jan"

        Feb ->
            "Feb"

        Mar ->
            "Mar"

        Apr ->
            "Apr"

        May ->
            "May"

        Jun ->
            "Jun"

        Jul ->
            "Jul"

        Aug ->
            "Aug"

        Sep ->
            "Sep"

        Oct ->
            "Oct"

        Nov ->
            "Nov"

        Dec ->
            "Dec"
