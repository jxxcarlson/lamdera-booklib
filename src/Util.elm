module Util exposing (comparePosix, ifApply, insertInList)

import List.Extra
import Time


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
