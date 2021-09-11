module Backend exposing (..)

import Authentication
import Backend.Backup
import Backend.Cmd
import Backend.Update
import Data
import Dict
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import List.Extra
import Random
import Time
import Types exposing (..)
import User
import Util


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

      -- SYSTEM
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
            let
                newModel =
                    if Util.isUTCTime 4 59 0 time then
                        Backend.Update.userReadingRates model

                    else
                        model
            in
            ( { newModel | currentTime = time }, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        -- ADMIN
        RunTask ->
            ( model, Cmd.none )

        EncodeBackendModel ->
            ( model, sendToFrontend clientId (GotBackup (Backend.Backup.encodeBackup model)) )

        RestoreBackup backendModel ->
            ( backendModel, sendToFrontend clientId (SendMessage "... backup restored") )

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

        SaveData username data ->
            let
                dataDict =
                    List.foldl (\datum dataDictAcc -> Data.insertDatum username datum dataDictAcc) model.dataDict data

                message =
                    case Dict.get username dataDict of
                        Nothing ->
                            "No dataDict"

                        Just dataFile ->
                            "SaveData:  " ++ String.fromInt (List.length dataFile.data)
            in
            ( { model | dataDict = dataDict }, sendToFrontend clientId (SendMessage message) )

        UpdateDatum user deltaPagesReadToday book ->
            case Dict.get user.username model.dataDict of
                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage "Can't update: no datafile") )

                Just dataFile ->
                    let
                        newData : List Data.Book
                        newData =
                            List.Extra.setIf (\b -> b.id == book.id) book dataFile.data

                        newDataFile =
                            { dataFile
                                | data = newData
                                , pagesReadToday = dataFile.pagesReadToday + deltaPagesReadToday
                                , pagesRead = dataFile.pagesRead + deltaPagesReadToday
                                , modificationDate = model.currentTime
                            }

                        newDataDict =
                            Dict.insert user.username newDataFile model.dataDict
                    in
                    ( { model | dataDict = newDataDict }
                    , Cmd.batch
                        [ sendToFrontend clientId (SendMessage <| "Pages read: " ++ (String.fromInt <| user.pagesReadToday + deltaPagesReadToday))
                        , sendToFrontend clientId (GotData newDataFile)
                        ]
                    )

        DeleteBookFromStore username dataId ->
            ( { model | dataDict = Data.remove username dataId model.dataDict }
            , sendToFrontend clientId (SendMessage <| "Item " ++ dataId ++ " removed")
            )

        SendUserData username ->
            case Dict.get username model.dataDict of
                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage "No data!") )

                Just dataFile ->
                    ( model, sendToFrontend clientId (GotData dataFile) )

        SendAllUserData ->
            ( model, sendToFrontend clientId (GotAllUserData (Backend.Update.allUsersSummary model)) )

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
                            , Backend.Cmd.sendUserData username clientId model
                            , sendToFrontend clientId (SendUser userData.user)
                            ]
                        )

                    else
                        ( model, sendToFrontend clientId (SendMessage <| "Sorry, password and username don't match") )

                Nothing ->
                    Backend.Update.setupUser model clientId username transitPassword
