module Backend.Update exposing
    ( allUsersSummary
    , currentReadingRate
    , gotAtomsphericRandomNumber
    , setupUser
    , userReadingRates
    )

import Authentication
import Data
import DateTime
import Dict
import Hex
import Lamdera exposing (ClientId, broadcast, sendToFrontend)
import Maybe.Extra
import Random
import Time
import Token
import Types exposing (..)
import User exposing (User)


type alias Model =
    BackendModel



-- SYSTEM


gotAtomsphericRandomNumber : Model -> Result error String -> ( Model, Cmd msg )
gotAtomsphericRandomNumber model result =
    case result of
        Ok str ->
            case String.toInt (String.trim str) of
                Nothing ->
                    ( model, Cmd.none )

                Just rn ->
                    let
                        newRandomSeed =
                            Random.initialSeed rn
                    in
                    ( { model
                        | randomAtmosphericInt = Just rn
                        , randomSeed = newRandomSeed
                      }
                    , broadcast (SendMessage <| "Got random atmospheric integer: " ++ String.fromInt rn)
                    )

        Err _ ->
            ( model, broadcast (SendMessage "Could not get random atmospheric integer") )



-- USER


userSummary : Model -> Username -> Maybe UserInfo
userSummary model username =
    case Dict.get username model.dataDict of
        Nothing ->
            Nothing

        Just dataFile ->
            let
                pages =
                    List.map .pages dataFile.data |> List.sum

                pagesRead =
                    List.map .pagesRead dataFile.data |> List.sum

                readingRate =
                    dataFile.readingRate
            in
            Just
                { name = username
                , books = List.length dataFile.data
                , pages = pages
                , pagesRead = pagesRead
                , pagesReadToday = dataFile.pagesReadToday
                , readingRate = readingRate
                }


readingRateFactor =
    0.5


currentReadingRate : Int -> Float -> Float
currentReadingRate pagesReadToday readingRate =
    if readingRate < 0.01 then
        toFloat pagesReadToday

    else
        readingRateFactor * (toFloat <| pagesReadToday) + (1 - readingRateFactor) * readingRate


userReadingRates : Model -> Model
userReadingRates model =
    let
        usernames =
            Dict.keys model.authenticationDict
    in
    List.foldl (\username model_ -> userReadingRate username model_) model usernames


userReadingRate : Username -> Model -> Model
userReadingRate username model =
    case Dict.get username model.dataDict of
        Nothing ->
            model

        Just dataFile ->
            let
                r =
                    0.5

                pagesRead1 =
                    dataFile.pagesRead

                pagesRead =
                    List.map .pagesRead dataFile.data |> List.sum

                pagesReadToday =
                    pagesRead - pagesRead1

                rate =
                    currentReadingRate dataFile.pagesReadToday dataFile.readingRate

                newDataFile =
                    { dataFile | pagesReadToday = 0, readingRate = rate }
            in
            { model | dataDict = Dict.insert username newDataFile model.dataDict }


allUsersSummary : Model -> List UserInfo
allUsersSummary model =
    List.map (userSummary model) (Dict.keys model.dataDict) |> Maybe.Extra.values


setupUser : Model -> ClientId -> String -> String -> ( BackendModel, Cmd BackendMsg )
setupUser model clientId username transitPassword =
    let
        ( randInt, seed ) =
            Random.step (Random.int (Random.minInt // 2) (Random.maxInt - 1000)) model.randomSeed

        randomHex =
            Hex.toString randInt |> String.toUpper

        tokenData =
            Token.get seed

        user =
            { username = username
            , id = tokenData.token
            , realname = "Undefined"
            , email = "Undefined"
            , created = model.currentTime
            , modified = model.currentTime
            , pagesReadToday = 0
            }
    in
    case Authentication.insert user randomHex transitPassword model.authenticationDict of
        Err str ->
            ( { model | randomSeed = seed }, sendToFrontend clientId (SendMessage ("Error: " ++ str)) )

        Ok authDict ->
            ( { model | randomSeed = seed, authenticationDict = authDict, dataDict = Data.setupUser model.currentTime user.username model.dataDict }
            , Cmd.batch
                [ sendToFrontend clientId (SendMessage "Success! You have set up your account")
                , sendToFrontend clientId (SendUser user)
                ]
            )
