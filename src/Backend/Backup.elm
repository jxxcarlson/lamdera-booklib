module Backend.Backup exposing (backupCodec)

import Codec exposing(Codec)
import Data
import Authentication
import Credentials
import Time
import User

type alias Backup =
    { dataDict : Data.DataDict
    , authenticationDict : Authentication.AuthenticationDict
    }


backupCodec : Codec Backup
backupCodec = Codec.object Backup
   |> Codec.field "dataDict" .dataDict (Codec.dict dataFileCodec)
   |> Codec.field "authenticationDict" .authenticationDict (Codec.dict userDataCodec)
   |> Codec.buildObject


authenticationDictCodec : Codec Authentication.AuthenticationDict
authenticationDictCodec = Codec.dict userDataCodec


userCodec : Codec User.User
userCodec = Codec.object User.User
   |> Codec.field "username" .username Codec.string
   |> Codec.field "id" .id Codec.string
   |> Codec.field "realname" .realname Codec.string
   |> Codec.field "email" .email Codec.string
   |> Codec.field "created" .created posixCodec
   |> Codec.field "modified" .modified posixCodec
   |> Codec.buildObject



credentialsCodec  : Codec Credentials.Credentials
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
userDataCodec = Codec.object Authentication.UserData
   |> Codec.field "user" .user userCodec
   |> Codec.field "credentials" .credentials credentialsCodec
   |> Codec.buildObject


dataFileCodec : Codec Data.DataFile
dataFileCodec = Codec.object Data.DataFile
    |> Codec.field "data" .data (Codec.list bookCodec)
    |> Codec.field "username" .username Codec.string
    |> Codec.field "creationDate" .creationDate posixCodec
    |> Codec.field "modificationDate" .modificationDate posixCodec
    |> Codec.field "pagesRead" .pagesRead Codec.int
    |> Codec.field "pagesReadToday" .pagesReadToday Codec.int
    |> Codec.field "readingRate" .readingRate Codec.float
    |> Codec.buildObject


bookCodec : Codec Data.Book
bookCodec = Codec.object Data.Book
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
posixCodec = Codec.map Time.millisToPosix Time.posixToMillis Codec.int





