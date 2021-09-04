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
            [ header model, viewUserData model.userData ]


header : FrontendModel -> Element FrontendMsg
header model =
    E.row [ E.spacing 12 ]
        [ E.el [ Font.size 18 ] (E.text "Admin")
        ]


viewUserData : List { name : String, books : Int, pages : Int, pagesRead : Int } -> Element msg
viewUserData userData =
    E.column
        [ E.spacing 8
        ]
        (List.map viewUserDatum userData)


viewUserDatum : { name : String, books : Int, pages : Int, pagesRead : Int } -> Element msg
viewUserDatum datum =
    let
        w =
            40
    in
    E.row [ E.spacing 8, E.width (E.px 450) ]
        [ E.el [ E.width (E.px 130) ] (E.text datum.name)
        , item (String.fromInt datum.books)
        , item (String.fromInt datum.pagesRead)
        , item (String.fromInt datum.pages)
        , item (String.fromInt (ratio datum))
        ]


ratio datum =
    let
        a =
            datum.pagesRead |> toFloat

        b =
            datum.pages |> toFloat
    in
    round ((100.0 * a) / b)


item str =
    E.el [ E.width (E.px 50) ] (E.el [ E.alignRight ] (E.text <| str))
