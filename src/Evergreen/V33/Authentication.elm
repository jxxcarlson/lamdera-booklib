module Evergreen.V33.Authentication exposing (..)

import Dict
import Evergreen.V33.Credentials
import Evergreen.V33.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V33.User.User
    , credentials : Evergreen.V33.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
