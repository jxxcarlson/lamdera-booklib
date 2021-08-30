module Library.ParserTools exposing ( Step(..)
    , StringData
    , between
    , char
    , first
    , loop
    , many
    , manyNonEmpty
    , manySeparatedBy
    , mapLoop
    , maybe
    , oneChar
    , optional
    , optionalList
    , prefixFreeOf
    , prefixWith
    , second
    , text
    )

import Parser exposing ((|.), (|=), Parser)



type alias StringData =
    { start : Int, finish : Int, content : String }


{-| Apply a parser zero or more times and return a list of the results.
-}
many : Parser a -> Parser (List a)
many p =
    Parser.loop [] (manyHelp p)


manySeparatedBy : Parser () -> Parser a -> Parser (List a)
manySeparatedBy sep p =
    manyNonEmpty_ p (second sep p)


manyHelp : Parser a -> List a -> Parser (Parser.Step (List a) (List a))
manyHelp p vs =
    Parser.oneOf
        [ Parser.end |> Parser.map (\_ -> Parser.Done (List.reverse vs))
        , Parser.succeed (\v -> Parser.Loop (v :: vs))
            |= p
        , Parser.succeed ()
            |> Parser.map (\_ -> Parser.Done (List.reverse vs))
        ]


manyNonEmpty : Parser a -> Parser (List a)
manyNonEmpty p =
    p
        |> Parser.andThen (\x -> manyWithInitialList [ x ] p)


manyNonEmpty_ : Parser a -> Parser a -> Parser (List a)
manyNonEmpty_ p q =
    p
        |> Parser.andThen (\x -> manyWithInitialList [ x ] q)


manyWithInitialList : List a -> Parser a -> Parser (List a)
manyWithInitialList initialList p =
    Parser.loop initialList (manyHelp p)


{-| Running `optional p` means run p, but if it fails, succeed anyway
-}
optional : Parser () -> Parser ()
optional p =
    Parser.oneOf [ p, Parser.succeed () ]


{-| Running `optional p` means run p. If the parser succeeds with value _result_,
return _Just result_ . If the parser fails, return Nothing.
-}
maybe : Parser a -> Parser (Maybe a)
maybe p =
    Parser.oneOf [ p |> Parser.map (\x -> Just x), Parser.succeed () |> Parser.map (\_ -> Nothing) ]


{-| Running `optionalList p` means run p, but if it fails, succeed anyway,
returning the empty list
-}
optionalList : Parser (List a) -> Parser (List a)
optionalList p =
    Parser.oneOf [ p, Parser.succeed () |> Parser.map (\_ -> []) ]


{-| running `first p q` means run p, then run q
and return the result of running p.
-}
first : Parser a -> Parser b -> Parser a
first p q =
    p |> Parser.andThen (\x -> q |> Parser.map (\_ -> x))


{-| running `second p q` means run p, then run q
and return the result of running q.
-}
second : Parser a -> Parser b -> Parser b
second p q =
    p |> Parser.andThen (\_ -> q)


{-| Running between p q r runs p, then q, then r, returning the result of p:

> run (between (Parser.symbol "[") Parser.int (Parser.symbol "]")) "[12]"
> Ok 12

-}
between : Parser a -> Parser b -> Parser c -> Parser b
between p q r =
    p |> Parser.andThen (\_ -> q) |> Parser.andThen (\x -> r |> Parser.map (\_ -> x))


{-| textPS = "text prefixText stopCharacters": Get the longest string
whose first character satisfies the prefixTest and whose remaining
characters are not in the list of stop characters. Example:

    line =
        textPS (\c -> Char.isAlpha) [ '\n' ]

recognizes lines that start with an alphabetic character.

-}
textPS : (Char -> Bool) -> List Char -> Parser { start : Int, finish : Int, content : String }
textPS prefixTest stopChars =
    Parser.succeed (\start finish content -> { start = start, finish = finish, content = String.slice start finish content })
        |= Parser.getOffset
        |. Parser.chompIf (\c -> prefixTest c)
        |. Parser.chompWhile (\c -> not (List.member c stopChars))
        |= Parser.getOffset
        |= Parser.getSource


{-| Get the longest string
whose first character satisfies `prefix` and whose remaining
characters satisfy `continue`. Example:

    line =
        textPS (\c -> Char.isAlpha) [ '\n' ]

recognizes lines that start with an alphabetic character.

-}
text : (Char -> Bool) -> (Char -> Bool) -> Parser { start : Int, finish : Int, content : String }
text prefix continue =
    Parser.succeed (\start finish content -> { start = start, finish = finish, content = String.slice start finish content })
        |= Parser.getOffset
        |. Parser.chompIf (\c -> prefix c) 
        |. Parser.chompWhile (\c -> continue c)
        |= Parser.getOffset
        |= Parser.getSource


char : (Char -> Bool) -> Parser { start : Int, finish : Int, content : String }
char prefixTest =
    Parser.succeed (\start finish content -> { start = start, finish = finish, content = String.slice start finish content })
        |= Parser.getOffset
        |. Parser.chompIf (\c -> prefixTest c) 
        |= Parser.getOffset
        |= Parser.getSource


oneChar : Parser String
oneChar =
    Parser.succeed (\begin end data -> String.slice begin end data)
        |= Parser.getOffset
        |. Parser.chompIf (\c -> True) 
        |= Parser.getOffset
        |= Parser.getSource



-- LOOP


type Step state a
    = Loop state
    | Done a


loop : state -> (state -> Step state a) -> a
loop s nextState =
    case nextState s of
        Loop s_ ->
            loop s_ nextState

        Done b ->
            b


mapLoop : (state -> Step state a) -> Step state a -> Step state a
mapLoop f stepState =
    case stepState of
        Loop s ->
            f s

        Done a ->
            Done a


{-| Return the longest prefix beginning with the supplied Char.
-}
prefixWith : Char -> String -> StringData
prefixWith c str =
    case Parser.run (text (\c_ -> c_ == c) (\c_ -> c_ == c)) str of
        Ok stringData ->
            stringData

        Err _ ->
            { content = "", finish = 0, start = 0 }


{-| Return the longest free of the supplied Char.
-}
prefixFreeOf : Char -> String -> StringData
prefixFreeOf c str =
    case Parser.run (text (\c_ -> c_ /= c) (\c_ -> c_ /= c)) str of
        Ok stringData ->
            stringData

        Err _ ->
            { content = "", finish = 0, start = 0 }
