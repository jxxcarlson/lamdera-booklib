module User exposing (User, defaultUser, guest)

import Time


type alias User =
    { username : String
    , id : String
    , realname : String
    , email : String
    , created : Time.Posix
    , modified : Time.Posix
    }


defaultUser =
    { username = "jxxcarlson"
    , id = "ekvdo-oaeaw"
    , realname = "James Carlson"
    , email = "jxxcarlson@gmail.com"
    , created = Time.millisToPosix 0
    , modified = Time.millisToPosix 0
    }


guest =
    { username = "guest"
    , id = "ekvdo-tseug"
    , realname = "Guest"
    , email = "guest@nonexistent.com"
    , created = Time.millisToPosix 0
    , modified = Time.millisToPosix 0
    }
