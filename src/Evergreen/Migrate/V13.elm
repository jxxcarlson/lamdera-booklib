module Evergreen.Migrate.V13 exposing (..)

import Dict
import Evergreen.V13.Authentication
import Evergreen.V13.Credentials
import Evergreen.V13.Data
import Evergreen.V13.Types as New
import Evergreen.V13.User
import Evergreen.V9.Authentication
import Evergreen.V9.Credentials
import Evergreen.V9.Data
import Evergreen.V9.Types as Old
import Evergreen.V9.User
import Lamdera.Migrations exposing (..)


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelMigrated
        ( { message = old.message

          -- SYSTEM
          , randomSeed = old.randomSeed
          , randomAtmosphericInt = old.randomAtmosphericInt
          , currentTime = old.currentTime

          -- DATA
          , dataDict = Dict.map (\k v -> transformDataFile v) old.dataDict

          -- USER
          , authenticationDict = Dict.map (\k v -> identUserData v) old.authenticationDict
          }
        , Cmd.none
        )


transformDataFile : Evergreen.V9.Data.DataFile -> Evergreen.V13.Data.DataFile
transformDataFile old =
    { data = old.data
    , username = old.username
    , creationDate = old.creationDate
    , modificationDate = old.modificationDate
    , pagesRead = 0
    , pagesReadToday = 0
    , readingRate = 0
    }



identUserData : Evergreen.V9.Authentication.UserData -> Evergreen.V13.Authentication.UserData
identUserData old =
    { user = identUser old.user, credentials = identCredentials old.credentials }



identUser : Evergreen.V9.User.User -> Evergreen.V13.User.User
identUser old =
    { username = old.username
    , id = old.id
    , realname = old.realname
    , email = old.email
    , created = old.created
    , modified = old.modified
    }


identCredentials : Evergreen.V9.Credentials.Credentials -> Evergreen.V13.Credentials.Credentials
identCredentials (Evergreen.V9.Credentials.V1 s t) =
    Evergreen.V13.Credentials.V1 s t


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



-- NOT NEEDED:


identBook : Evergreen.V9.Data.Book -> Evergreen.V13.Data.Book
identBook old =
    { id = old.id
    , username = old.username
    , title = old.title
    , subtitle = old.subtitle
    , author = old.author
    , notes = old.notes
    , pages = old.pages
    , pagesRead = old.pagesRead
    , rating = old.rating
    , public = old.public
    , category = old.category
    , creationDate = old.creationDate
    , modificationDate = old.modificationDate
    , finishDate = old.finishDate
    , pagesReadToday = old.pagesReadToday
    , averageReadingRate = old.averageReadingRate
    }
