module Library.HMParser exposing (getMinutes)


import Parser exposing (..)


{-|

    > parseMinutes "02:34"
    Just 154 :

-}
getMinutes : String -> Maybe Int
getMinutes str =
    case run minutesParser str of
        Ok val ->
            val

        Err _ ->
            Nothing


pairParser : Parser (Maybe ( Int, Int ))
pairParser =
    (succeed (\a b -> ( a, b ))
        |= (item |> map stripLeadingZero)
        |. symbol ":"
        |= (item |> map stripLeadingZero)
    )
        |> map (\( a, b ) -> join ( String.toInt a, String.toInt b ))


minutesParser : Parser (Maybe Int)
minutesParser =
    pairParser |> map (Maybe.map minutesOfPair)


minutesOfPair : ( Int, Int ) -> Int
minutesOfPair ( hours, minutes ) =
    60 * hours + minutes


item : Parser String
item =
    getChompedString <|
        chompUntilEndOr ":"


join : ( Maybe a, Maybe b ) -> Maybe ( a, b )
join ( ma, mb ) =
    case ( ma, mb ) of
        ( Nothing, _ ) ->
            Nothing

        ( _, Nothing ) ->
            Nothing

        ( Just a, Just b ) ->
            Just ( a, b )


stripLeadingZero : String -> String
stripLeadingZero str =
    if String.left 1 str == "0" then
        String.dropLeft 1 str

    else
        str
