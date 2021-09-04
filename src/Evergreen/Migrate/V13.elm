module Evergreen.Migrate.V13 exposing (..)

import Dict
import Evergreen.V13.Authentication
import Evergreen.V13.Data
import Evergreen.V13.Types as New
import Evergreen.V9.Authentication
import Evergreen.V9.Data
import Evergreen.V9.Types as Old
import Lamdera.Migrations exposing (..)


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelMigrated
        ( { message = ""

          -- SYSTEM
          , randomSeed = old.randomSeed
          , randomAtmosphericInt = old.randomAtmosphericInt
          , currentTime = old.currentTime

          -- DATA
          , dataDict = identDataDict old.dataDict

          -- USER
          , authenticationDict = identAuthenticationDict old.authenticationDict
          }
        , Cmd.none
        )


identDataDict : Evergreen.V9.Data.DataDict -> Evergreen.V13.Data.DataDict
identDataDict oldDict =
    let
        oldUsers =
            Dict.keys oldDict

        insert username dict =
            case Dict.get username dict of
                Nothing ->
                    dict

                Just userData ->
                    Dict.insert username userData dict
    in
    List.foldl (\username dict -> insert username dict) Dict.empty oldUsers


identAuthenticationDict : Evergreen.V9.Authentication.AuthenticationDict -> Evergreen.V13.Authentication.AuthenticationDict
identAuthenticationDict oldDict =
    let
        oldUsers =
            Dict.keys oldDict

        insert username dict =
            case Dict.get username dict of
                Nothing ->
                    dict

                Just userData ->
                    Dict.insert username userData dict
    in
    List.foldl (\username dict -> insert username dict) Dict.empty oldUsers


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    MsgUnchanged
