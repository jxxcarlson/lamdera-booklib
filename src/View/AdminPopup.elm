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
        -- data = List.sortBy (\item_ -> item_.pagesRead) model.userData |> List.reverse
        data =
            List.sortBy (\item_ -> item_.creationDate) model.userData |> List.reverse

        wHeight =
            model.windowHeight

        wWidth =
            700
    in
    View.Utility.showIf (model.popupStatus == PopupOpen AdminPopup) <|
        E.column
            [ E.width (E.px wWidth)
            , E.height (E.px (wHeight - 160))
            , Font.size 14
            , Font.color (E.rgb255 0 0 0)
            , Background.color View.Color.transparentBlue
            , E.moveUp (toFloat <| model.windowHeight - 198)
            , E.moveRight 380
            , E.paddingXY 18 18
            , E.spacing 12
            ]
            [ header model, viewUserData wWidth (wHeight - 190) data, footer model ]


footer : FrontendModel -> Element FrontendMsg
footer model =
    E.row [ E.spacing 12 ]
        [ View.Utility.showIf (Maybe.map .username model.currentUser == Just "jxxcarlson") Button.backupBackendModel

        -- , View.Utility.showIf (Maybe.map .username model.currentUser == Just "jxxcarlson") Button.restoreBackendBackup
        ]


header : FrontendModel -> Element FrontendMsg
header model =
    E.row [ E.spacing 12 ]
        [ E.el [ Font.size 18, Font.bold ] (E.text "Admin")
        , Button.closePopup
        ]


viewUserData : Int -> Int -> List UserInfo -> Element msg
viewUserData wWidth panelHeight userData =
    let
        n =
            List.length userData
    in
    E.column
        [ E.spacing 8
        , E.height (E.px panelHeight)
        , E.scrollbarY
        , E.width (E.px (wWidth - 30))
        ]
        (E.row [] [ E.el [ Font.size 14, Font.bold ] (E.text <| "Users: "), E.el [ Font.size 14 ] (E.text <| String.fromInt n) ]
            :: columnHeadings
            :: List.map (viewUserDatum wWidth) userData
        )


viewUserDatum : Int -> UserInfo -> Element msg
viewUserDatum wWidth datum =
    E.row [ E.spacing 8, E.width (E.px (wWidth - 60)) ]
        [ E.el [ E.width (E.px 160) ] (E.text datum.name)
        , item datum.creationDate
        , item (String.fromInt datum.books)
        , item (String.fromInt datum.pagesRead)
        , item (String.fromInt datum.pages)
        , item (ratio datum)
        , item (String.fromInt datum.pagesReadToday)
        , item (String.fromFloat <| Util.roundTo 2 datum.readingRate)
        ]


columnHeadings =
    E.row [ E.spacing 8, E.width (E.px 500) ]
        [ E.el [ E.width (E.px 160), Font.bold ] (E.text "Name")
        , item2 "Joined"
        , item2 "Books"
        , item2 "P. read"
        , item2 "Pages"
        , item2 "Ratio"
        , item2 "Today"
        , item2 "Rate"
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


item2 str =
    E.el [ E.width (E.px 50), Font.bold ] (E.el [ E.alignRight ] (E.text <| str))
