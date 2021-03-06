module Backend.RestorePrevious exposing (decodeBackup)

import Authentication
import Codec exposing (Codec)
import Credentials
import Data
import Random
import Time
import Types exposing (BackendModel)
import User


type alias OldUser =
    { username : String
    , id : String
    , realname : String
    , email : String
    , created : Time.Posix
    , modified : Time.Posix
    }


type alias Backup =
    { dataDict : Data.DataDict, authenticationDict : Authentication.AuthenticationDict }


encodeBackup : BackendModel -> String
encodeBackup model =
    let
        backup =
            { authenticationDict = model.authenticationDict, dataDict = model.dataDict }
    in
    Codec.encodeToString 4 backupCodec backup


decodeBackup : String -> Result Codec.Error BackendModel
decodeBackup str =
    let
        result =
            Codec.decodeString backupCodec str
    in
    case result of
        Ok backup ->
            Ok
                { message = "backup "
                , randomSeed = Random.initialSeed 876543
                , randomAtmosphericInt = Nothing
                , currentTime = Time.millisToPosix 0
                , dataDict = backup.dataDict
                , authenticationDict = backup.authenticationDict
                }

        Err x ->
            Err x


backupCodec : Codec Backup
backupCodec =
    Codec.object Backup
        |> Codec.field "dataDict" .dataDict (Codec.dict dataFileCodec)
        |> Codec.field "authenticationDict" .authenticationDict (Codec.dict userDataCodec)
        |> Codec.buildObject


authenticationDictCodec : Codec Authentication.AuthenticationDict
authenticationDictCodec =
    Codec.dict userDataCodec


oldUserCodec : Codec OldUser
oldUserCodec =
    Codec.object OldUser
        |> Codec.field "username" .username Codec.string
        |> Codec.field "id" .id Codec.string
        |> Codec.field "realname" .realname Codec.string
        |> Codec.field "email" .email Codec.string
        |> Codec.field "created" .created posixCodec
        |> Codec.field "modified" .modified posixCodec
        |> Codec.buildObject


oldUserToUser : OldUser -> User.User
oldUserToUser oldUser =
    { username = oldUser.username
    , id = oldUser.id
    , realname = oldUser.realname
    , email = oldUser.email
    , created = oldUser.created
    , modified = oldUser.modified
    , pagesReadToday = 0
    }


userToOldUser : User.User -> OldUser
userToOldUser user =
    { username = user.username
    , id = user.id
    , realname = user.realname
    , email = user.email
    , created = user.created
    , modified = user.modified
    }


credentialsCodec : Codec Credentials.Credentials
credentialsCodec =
    Codec.custom
        (\credentials value ->
            case value of
                Credentials.V1 ss tt ->
                    credentials ss tt
        )
        |> Codec.variant2 "Credentials" Credentials.V1 Codec.string Codec.string
        |> Codec.buildCustom


userDataCodec : Codec Authentication.UserData
userDataCodec =
    Codec.object Authentication.UserData
        |> Codec.field "user" .user (oldUserCodec |> Codec.map oldUserToUser userToOldUser)
        |> Codec.field "credentials" .credentials credentialsCodec
        |> Codec.buildObject


dataFileCodec : Codec Data.DataFile
dataFileCodec =
    Codec.object Data.DataFile
        |> Codec.field "data" .data (Codec.list bookCodec)
        |> Codec.field "username" .username Codec.string
        |> Codec.field "creationDate" .creationDate posixCodec
        |> Codec.field "modificationDate" .modificationDate posixCodec
        |> Codec.field "pagesRead" .pagesRead Codec.int
        |> Codec.field "pagesReadToday" .pagesReadToday Codec.int
        |> Codec.field "readingRate" .readingRate Codec.float
        |> Codec.buildObject


bookCodec : Codec Data.Book
bookCodec =
    Codec.object Data.Book
        |> Codec.field "id" .id Codec.string
        |> Codec.field "username" .username Codec.string
        |> Codec.field "title" .title Codec.string
        |> Codec.field "subtitle" .subtitle Codec.string
        |> Codec.field "author" .author Codec.string
        |> Codec.field "notes" .id Codec.string
        |> Codec.field "pages" .pages Codec.int
        |> Codec.field "pagesRead" .pagesRead Codec.int
        |> Codec.field "rating" .rating Codec.int
        |> Codec.field "public" .public Codec.bool
        |> Codec.field "category" .category Codec.string
        |> Codec.field "creationDate" .creationDate posixCodec
        |> Codec.field "modificationDate" .modificationDate posixCodec
        |> Codec.nullableField "finishDate" .finishDate posixCodec
        |> Codec.field "pagesReadToday" .pagesReadToday Codec.int
        |> Codec.field "averageReadingRate" .averageReadingRate Codec.float
        |> Codec.buildObject


posixCodec : Codec Time.Posix
posixCodec =
    Codec.map Time.millisToPosix Time.posixToMillis Codec.int
