module Backend.Update exposing
    ( allUsersSummary
    , gotAtomsphericRandomNumber
    , setupUser
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


userSummary : Model -> Username -> Maybe { name : Username, books : Int, pages : Int, pagesRead : Int }
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
            in
            Just { name = username, books = List.length dataFile.data, pages = pages, pagesRead = pagesRead }


allUsersSummary : Model -> List { name : Username, books : Int, pages : Int, pagesRead : Int }
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
            { username = username, id = tokenData.token, realname = "Undefined", email = "Undefined", created = model.currentTime, modified = model.currentTime }
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


isUTCTime : Int -> Int -> Time.Posix -> Bool
isUTCTime hours minutes t =
    let
        dt =
            DateTime.fromPosix t

        h =
            DateTime.getHours dt

        m =
            DateTime.getMinutes dt
    in
    h == hours && m == minutes
