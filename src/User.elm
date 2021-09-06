module User exposing (User, defaultUser, guest)

import Time


type alias User =
    { username : String
    , id : String
    , realname : String
    , email : String
    , created : Time.Posix
    , modified : Time.Posix
    , pagesReadToday : Int
    }


defaultUser =
    { username = "jxxcarlson"
    , id = "ekvdo-oaeaw"
    , realname = "James Carlson"
    , email = "jxxcarlson@gmail.com"
    , created = Time.millisToPosix 0
    , modified = Time.millisToPosix 0
    , pagesReadToday = 0
    }


guest =
    { username = "guest"
    , id = "ekvdo-tseug"
    , realname = "Guest"
    , email = "guest@nonexistent.com"
    , created = Time.millisToPosix 0
    , modified = Time.millisToPosix 0
    , pagesReadToday = 0
    }
