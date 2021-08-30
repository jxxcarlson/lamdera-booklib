module Search exposing (search,  searchWithTerm,SearchConfig(..))

{-|

@docs search, SearchConfig

-}

import APITypes exposing (SearchTarget, Term(..), targetContent, targetDate)
import Parse exposing (parse)
import Time


{-| -}
type SearchConfig
    = CaseSensitive
    | NotCaseSensitive


{-| -}
search : (a -> SearchTarget) -> SearchConfig -> String ->  List a -> List a
search transformer config  queryString  dataList =
    case parse queryString of
        Ok term ->
            searchWithTerm transformer config  term dataList

        Err _ ->
            dataList


searchWithTerm :  (a -> SearchTarget) -> SearchConfig -> Term -> List a -> List a
searchWithTerm transformer config  term dataList =
    List.filter (query transformer config  term) dataList


query : (a -> SearchTarget) -> SearchConfig ->  Term -> a -> Bool
query transformer config  term =
    case term of
        Word str ->
            case config of
                CaseSensitive ->
                    \datum -> (targetContent transformer datum) == str

                NotCaseSensitive ->
                    \datum -> String.toLower (targetContent transformer datum) == String.toLower str

        NotWord str ->
            case config of
                CaseSensitive ->
                    \datum -> (targetContent transformer datum) /= str

                NotCaseSensitive ->
                    \datum -> String.toLower (targetContent transformer datum) /= String.toLower str

        Conjunction terms ->
            \datum -> List.foldl (\term_ acc -> match transformer config  term_ datum && acc) True terms

        BeforeDateTime dt ->
            \datum -> posixLTE (targetDate transformer datum) dt

        AfterDateTime dt ->
            \datum -> posixGTE (targetDate transformer datum) dt

        Range dt1 dt2 ->
            \datum -> posixGTE (targetDate transformer datum) dt1 && posixLTE (targetDate transformer datum) dt2


posixGTE a b =
    Time.posixToMillis a >= Time.posixToMillis b



posixLTE a b =
    Time.posixToMillis a <= Time.posixToMillis b


posixZero =
    Time.millisToPosix 0


match : (a -> SearchTarget) -> SearchConfig -> Term ->  a -> Bool
match transformer config  term datum =
    case term of
        Word w ->
            case config of
                CaseSensitive ->
                    String.contains w (targetContent transformer datum)

                NotCaseSensitive ->
                    String.contains (String.toLower w) (String.toLower (targetContent transformer datum))

        NotWord w ->
            case config of
                CaseSensitive ->
                    not (String.contains w (targetContent transformer datum))

                NotCaseSensitive ->
                    not (String.contains (String.toLower w) (String.toLower (targetContent transformer datum)))

        BeforeDateTime dt ->
            posixLTE (targetDate transformer datum) dt

        AfterDateTime dt ->
            posixGTE (targetDate transformer datum) dt

        Range dt1 dt2 ->
            posixGTE (targetDate transformer datum) dt1 && posixLTE (targetDate transformer datum) dt2

        _ ->
            False
