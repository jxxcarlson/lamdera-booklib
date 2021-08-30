module Sort exposing (sort, SortParam(..), Direction(..))

{-|

@docs sort, SortParam, Direction

-}

import APITypes exposing (SearchTarget, targetDate, targetContent, targetMillis)
import Random
import Random.List
import Time


{-| -}
type SortParam
    = Alpha Direction
    | DateTime Direction
    | Random Random.Seed



--| Random Int


{-| -}
type Direction
    = Increasing
    | Decreasing


{-| -}
type Filter
    = DateAfter String
    | DateBefore String


{-| -}
sort : (a -> SearchTarget) -> SortParam ->  List a -> List a
sort transform param  dataList =
    case param of
        Alpha Increasing ->
            List.sortWith (\a b -> compare (targetContent transform a) (targetContent transform b)) dataList

        Alpha Decreasing ->
            List.sortWith (\a b -> compare (targetContent transform b) (targetContent transform a)) dataList

        DateTime Increasing ->
            List.sortWith (\a b -> compare (targetMillis transform a) (targetMillis transform b)) dataList

        DateTime Decreasing ->
            List.sortWith (\a b -> compare (targetMillis transform b) (targetMillis transform a)) dataList

        Random seed ->
            Random.step (Random.List.shuffle dataList) seed |> Tuple.first
