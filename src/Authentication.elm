module Authentication exposing
    ( AuthenticationDict
    , encryptForTransit
    , insert
    , users
    , verify
    )

import Credentials exposing (Credentials)
import Crypto.HMAC exposing (sha256)
import Dict exposing (Dict)
import Env
import User exposing (User)


type alias Username =
    String


type alias UserData =
    { user : User, credentials : Credentials }


type alias AuthenticationDict =
    Dict Username UserData


users : AuthenticationDict -> List User
users authDict =
    authDict |> Dict.values |> List.map .user


insert : User -> String -> String -> AuthenticationDict -> Result String AuthenticationDict
insert user salt transitPassword authDict =
    if String.length user.username < 4 then
        Err "Sorry, your username must have at least four characters"

    else
        case Credentials.hashPw salt transitPassword of
            Err _ ->
                Err "Could not set you up. Sorry!"

            Ok credentials ->
                Ok (Dict.insert user.username { user = user, credentials = credentials } authDict)


encryptForTransit : String -> String
encryptForTransit str =
    Crypto.HMAC.digest sha256 Env.transitKey str


verify : String -> String -> AuthenticationDict -> Bool
verify username transitPassword authDict =
    case Dict.get username authDict of
        Nothing ->
            False

        Just data ->
            case Credentials.check transitPassword data.credentials of
                Ok () ->
                    True

                Err _ ->
                    False
