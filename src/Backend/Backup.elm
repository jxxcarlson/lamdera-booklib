module Backend.Backup exposing (..)

import Codec exposing(Codec)
import Data
import Authentication
import Types exposing (BackendModel)

backendCodec : Codec BackendModel
backendCodec = Codec.object BackupData
   |> Codec.field "dataDict" .dataDict Codec.dict dataFileCodec
   |> Codec.field "authenticationDict" .authenticationDict


dataFileCodec : Codec Data.DataFile
dataFileCodec = Debug.todo

dataFileCodec : Codec Authentication.UserData
dataFileCodec = Debug.todo


dataFileCode : Codec Data.DataFile
dataFileCode = Debug.todo
type alias BackupData
    {
      dataDict : Data.DataDict
    , authenticationDict : Authentication.AuthenticationDict
    }