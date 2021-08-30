module View.Popup exposing (admin)

import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Types exposing (FrontendModel, FrontendMsg(..), PopupStatus(..), PopupWindow(..))
import User exposing (User)
import View.Button as Button
import View.Color
import View.Utility


admin : FrontendModel -> Element FrontendMsg
admin model =
    View.Utility.showIf (model.popupStatus == PopupOpen AdminPopup) <|
        E.column
            [ E.width (E.px 500)
            , E.height (E.px 700)
            , Font.size 14
            , Font.color (E.rgb255 0 0 0)
            , Background.color View.Color.transparentBlue
            , E.moveUp (toFloat <| model.windowHeight - 198)
            , E.moveRight 380
            , E.paddingXY 18 18
            , E.spacing 12
            ]
            [ header model, viewUsers model.users ]


header : FrontendModel -> Element FrontendMsg
header model =
    E.row [ E.spacing 12 ]
        [ E.el [ Font.size 18 ] (E.text "Admin")
        , Button.getUsers
        ]


viewUsers : List User -> Element msg
viewUsers users =
    E.column
        [ E.spacing 8
        ]
        (List.map viewUser (List.sortBy (\user -> user.username) users))


viewUser : User -> Element msg
viewUser user =
    E.row
        [ E.spacing 8
        , E.width (E.px 450)
        ]
        [ E.el [] (E.text user.username) ]
