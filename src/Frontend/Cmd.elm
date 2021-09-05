module Frontend.Cmd exposing (exportJson, getRandomNumberFE, setupWindow)

import Browser.Dom as Dom
import Frontend.Codec
import File.Download as Download
import Http
import Task
import Types exposing (FrontendModel, FrontendMsg(..), ToBackend(..))


exportJson : FrontendModel -> Cmd msg
exportJson model =
    Download.string "books.json" "text/json" (Frontend.Codec.encodeData model.books)


setupWindow : Cmd FrontendMsg
setupWindow =
    Task.perform GotViewport Dom.getViewport


getRandomNumberFE : Cmd FrontendMsg
getRandomNumberFE =
    Http.get
        { url = randomNumberUrl 9
        , expect = Http.expectString GotAtomsphericRandomNumberFE
        }


{-| maxDigits < 10
-}
randomNumberUrl : Int -> String
randomNumberUrl maxDigits =
    let
        maxNumber =
            10 ^ maxDigits

        prefix =
            "https://www.random.org/integers/?num=1&min=1&max="

        suffix =
            "&col=1&base=10&format=plain&rnd=new"
    in
    prefix ++ String.fromInt maxNumber ++ suffix
