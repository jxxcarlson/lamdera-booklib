module Util exposing
    ( comparePosix
    , ifApply
    , insertInList
    , isUTCTime
    , liftToMaybe
    , roundTo
    , stringToInt
    )

import DateTime
import List.Extra
import Time


stringToInt : String -> Int
stringToInt str =
    String.toList str
        |> List.map (Char.toLower >> Char.toCode >> (\n -> n - 97))
        |> List.filter (\n -> n >= 0 && n < 26)
        |> List.indexedMap (\i n -> n * 26 ^ i)
        |> List.sum


isUTCTime : Int -> Int -> Int -> Time.Posix -> Bool
isUTCTime hours minutes seconds t =
    let
        dt =
            DateTime.fromPosix t

        h =
            DateTime.getHours dt

        m =
            DateTime.getMinutes dt

        s =
            DateTime.getSeconds dt
    in
    h == hours && m == minutes && s == seconds


liftToMaybe : (a -> b) -> (Maybe a -> Maybe b)
liftToMaybe f =
    \a ->
        case a of
            Nothing ->
                Nothing

            Just a_ ->
                Just (f a_)


comparePosix : Time.Posix -> Time.Posix -> Order
comparePosix a b =
    compare (Time.toMillis Time.utc a) (Time.toMillis Time.utc b)


insertInList : a -> List a -> List a
insertInList a list =
    if List.Extra.notMember a list then
        a :: list

    else
        list


{-| If the test succeeds, return `transform a`, otherwise
return `a`.
-}
ifApply : Bool -> (a -> a) -> a -> a
ifApply test transform a =
    if test then
        transform a

    else
        a


roundTo : Int -> Float -> Float
roundTo k x =
    let
        factor =
            10.0 ^ toFloat k

        x1 =
            round (factor * x)
    in
    toFloat x1 / factor
