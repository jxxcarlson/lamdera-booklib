module Backend exposing (..)

import Authentication
import Backend.Cmd
import Backend.Update
import Data
import Dict
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import List.Extra
import Random
import Time
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub BackendMsg
subscriptions model =
    Time.every 1000 Tick


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!"

      -- RANDOM
      , randomSeed = Random.initialSeed 12034
      , randomAtmosphericInt = Nothing
      , currentTime = Time.millisToPosix 0

      -- USER
      , authenticationDict = Dict.empty
      , dataDict = Dict.empty
      }
    , Backend.Cmd.getRandomNumber
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        GotAtomsphericRandomNumber result ->
            Backend.Update.gotAtomsphericRandomNumber model result

        Tick time ->
            ( { model | currentTime = time }, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        -- ADMIN
        RunTask ->
            ( model, Cmd.none )

        -- DATA
        SaveDatum username datum ->
            let
                dataDict =
                    Data.insertDatum username datum model.dataDict

                message =
                    case Dict.get username dataDict of
                        Nothing ->
                            "No dataDict"

                        Just dataFile ->
                            "Datum saved, items = " ++ String.fromInt (List.length dataFile.data)
            in
            ( { model | dataDict = dataDict }, sendToFrontend clientId (SendMessage message) )

        UpdateDatum username datum ->
            case Dict.get username model.dataDict of
                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage "Can't update: no datafile") )

                Just dataFile ->
                    let
                        newData : List Data.Book
                        newData =
                            List.Extra.setIf (\snip -> snip.id == datum.id) datum dataFile.data

                        newDataDict =
                            Dict.insert username { dataFile | data = newData } model.dataDict
                    in
                    ( { model | dataDict = newDataDict }, sendToFrontend clientId (SendMessage <| "Snippet '" ++ String.left 10 datum.title ++ " ... ' updated.") )

        DeleteSnippetFromStore username dataId ->
            ( { model | dataDict = Data.remove username dataId model.dataDict }
            , sendToFrontend clientId (SendMessage <| "Item " ++ dataId ++ " removed")
            )

        SendUserData username ->
            case Dict.get username model.dataDict of
                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage "No data!") )

                Just dataFile ->
                    ( model, sendToFrontend clientId (GotUserData dataFile.data) )

        SendUsers ->
            ( model, sendToFrontend clientId (GotUsers (Authentication.users model.authenticationDict)) )

        -- USER
        SignInOrSignUp username transitPassword ->
            case Dict.get username model.authenticationDict of
                Just userData ->
                    if Authentication.verify username transitPassword model.authenticationDict then
                        ( model
                        , Cmd.batch
                            [ sendToFrontend clientId
                                (SendMessage <|
                                    "Success! Random atmospheric integer: "
                                        ++ (Maybe.map String.fromInt model.randomAtmosphericInt |> Maybe.withDefault "NONE")
                                )
                            , Backend.Cmd.sendUserData Infinity username clientId model
                            , sendToFrontend clientId (SendUser userData.user)
                            ]
                        )

                    else
                        ( model, sendToFrontend clientId (SendMessage <| "Sorry, password and username don't match") )

                Nothing ->
                    Backend.Update.setupUser model clientId username transitPassword
