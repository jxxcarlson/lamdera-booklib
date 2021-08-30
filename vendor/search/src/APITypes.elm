module APITypes exposing (Term(..), SearchTarget, targetMillis, targetContent, targetDate)

{-|

@docs Term,  SearchTarget,  targetMillis, targetContent, targetDate

-}

import Time


{-| -}
type alias SearchTarget = {targetContent : String , targetDate : Time.Posix }


{-| -}
type Term
    = Word String
    | NotWord String
    | Conjunction (List Term)
    | BeforeDateTime Time.Posix
    | AfterDateTime Time.Posix
    | Range Time.Posix Time.Posix

{-| -}
targetContent : (a -> SearchTarget) -> a -> String
targetContent transform a =
    (transform a).targetContent

{-| -}
targetDate : (a -> SearchTarget) -> a -> Time.Posix
targetDate transform a =
    (transform a).targetDate

{-| -}
targetMillis : (a -> SearchTarget) -> a -> Int
targetMillis transform a =
    (transform a).targetDate |> Time.posixToMillis