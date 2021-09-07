module View.AdminPopup exposing (admin)

import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Types exposing (FrontendModel, FrontendMsg(..), PopupStatus(..), PopupWindow(..), UserInfo)
import User exposing (User)
import Util
import View.Button as Button
import View.Color
import View.Utility


admin : FrontendModel -> Element FrontendMsg
admin model =
    let
        data =
            List.sortBy (\item_ -> item_.pagesRead) model.userData |> List.reverse
    in
    View.Utility.showIf (model.popupStatus == PopupOpen AdminPopup) <|
        E.column
            [ E.width (E.px 600)
            , E.height (E.px 600)
            , Font.size 14
            , Font.color (E.rgb255 0 0 0)
            , Background.color View.Color.transparentBlue
            , E.moveUp (toFloat <| model.windowHeight - 198)
            , E.moveRight 380
            , E.paddingXY 18 18
            , E.spacing 12
            ]
            [ header model, viewUserData 500 data, footer model ]


footer : FrontendModel -> Element FrontendMsg
footer model =
    E.row [ E.spacing 12 ]
        [ View.Utility.showIf (Maybe.map .username model.currentUser == Just "jxxcarlson") Button.backupBackendModel

        --, View.Utility.showIf (Maybe.map .username model.currentUser == Just "jxxcarlson") Button.restoreBackendBackup
        ]


header : FrontendModel -> Element FrontendMsg
header model =
    E.row [ E.spacing 12 ]
        [ E.el [ Font.size 18, Font.bold ] (E.text "Admin")
        , Button.closePopup
        ]


viewUserData : Int -> List UserInfo -> Element msg
viewUserData panelHeight userData =
    let
        n =
            List.length userData
    in
    E.column
        [ E.spacing 8
        , E.height (E.px panelHeight)
        , E.scrollbarY
        ]
        (E.row [ Font.size 14 ] [ E.text <| "Users: " ++ String.fromInt n ] :: columnHeadings :: List.map viewUserDatum userData)


viewUserDatum : UserInfo -> Element msg
viewUserDatum datum =
    E.row [ E.spacing 8, E.width (E.px 500) ]
        [ E.el [ E.width (E.px 110) ] (E.text datum.name)
        , item (String.fromInt datum.books)
        , item (String.fromInt datum.pagesRead)
        , item (String.fromInt datum.pages)
        , item (ratio datum)
        , item (String.fromInt datum.pagesReadToday)
        , item (String.fromFloat <| Util.roundTo 2 datum.readingRate)
        ]


columnHeadings =
    E.row [ E.spacing 8, E.width (E.px 500) ]
        [ E.el [ E.width (E.px 110) ] (E.text "Name")
        , item "Books"
        , item "P. read"
        , item "Pages"
        , item "Ratio"
        , item "Today"
        , item "Rate"
        ]


ratio datum =
    let
        a =
            datum.pagesRead |> toFloat

        b =
            datum.pages |> toFloat
    in
    if a == 0 then
        "_"

    else
        String.fromInt <| round ((100.0 * a) / b)


item str =
    E.el [ E.width (E.px 50) ] (E.el [ E.alignRight ] (E.text <| str))
