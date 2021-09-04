module View.Small exposing (view)

import Data exposing (Book)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Html exposing (Html)
import Markdown
import Time
import Types exposing (..)
import View.AdminPopup
import View.Button as Button
import View.Color as Color
import View.Input
import View.Style
import View.Utility


type alias Model =
    FrontendModel


view : Model -> Html FrontendMsg
view model =
    E.layoutWith { options = [ E.focusStyle View.Utility.noFocus ] }
        [ View.Style.bgGray 0.2, E.clipX, E.clipY ]
        (mainView model)


mainView model =
    case model.currentUser of
        Nothing ->
            signInOrUpView model

        Just user ->
            case model.appMode of
                ViewBooksMode ->
                    case model.bookViewMode of
                        SnippetExpanded ->
                            viewSnippetExpanded model

                        SnippetCollapsed ->
                            listView model

                _ ->
                    itemview model


signInOrUpView model =
    E.column (mainColumnStyle model)
        [ E.column
            [ E.spacing 24
            , Background.color Color.blueGray
            , E.paddingXY 60 60
            , E.width E.fill
            , E.height E.fill
            ]
            [ E.el [ E.height (E.px 31), E.width E.fill, E.paddingXY 12 3, Background.color Color.paleBlue ]
                (E.el [ E.centerY ] (E.text model.message))
            , Button.signIn
            , View.Input.usernameInput model
            , View.Input.passwordInput model
            ]
        ]


listView : Model -> Element FrontendMsg
listView model =
    let
        filteredSnippets =
            Data.filter (String.trim model.inputBookFilter) model.books

        numberOfSnippets =
            String.fromInt (List.length model.books)

        numberOfFilteredSnippets =
            String.fromInt (List.length filteredSnippets)

        ratio =
            numberOfFilteredSnippets ++ "/" ++ numberOfSnippets
    in
    E.column (mainColumnStyle model)
        [ E.column [ E.spacing 12, E.width (E.px <| appWidth_ model), E.height (E.px (appHeight_ model - 45)), E.clipX, E.clipY ]
            [ E.row [ E.width (E.px <| appWidth_ model) ]
                [ title "Booklib"
                , userHeading model
                , E.el [ E.alignRight ] (Button.expandCollapseView model.viewMode)
                ]
            , E.column [ E.spacing 12 ]
                [ E.column [ E.spacing 12 ]
                    [ E.row [ E.spacing 8, E.width (E.px (appWidth_ model)) ]
                        [ View.Input.bookFilter model (appWidth_ model - 210)
                        , Button.searchByStarred
                        , E.el [ Font.color Color.white, Font.size 14, E.alignRight ] (E.text ratio)
                        ]
                    , viewSnippets model filteredSnippets
                    ]
                ]

            -- , footer model
            ]
        ]


itemview : Model -> Element FrontendMsg
itemview model =
    let
        filteredSnippets =
            Data.filter (String.trim model.inputBookFilter) model.books

        numberOfSnippets =
            String.fromInt (List.length model.books)

        numberOfFilteredSnippets =
            String.fromInt (List.length filteredSnippets)

        ratio =
            numberOfFilteredSnippets ++ "/" ++ numberOfSnippets
    in
    E.column (mainColumnStyle model)
        [ E.column [ E.spacing 12, E.width (E.px <| appWidth_ model), E.height (E.px (appHeight_ model)) ]
            [ E.row [ E.width (E.px <| appWidth_ model) ]
                [ title "Booklib"
                , userHeading model
                , E.el [ E.alignRight ] (Button.expandCollapseView model.viewMode)
                ]
            , header model
            , E.column [ E.spacing 12 ]
                [ E.column [ E.spacing 12 ]
                    [ E.none

                    -- ,View.Input.bookEditor (appWidth_ model) 100 model
                    , E.row [ E.spacing 8, E.width (E.px (appWidth_ model)) ]
                        [ E.none

                        -- View.Input.snippetFilter model (appWidth_ model - 210)
                        --, Button.searchByStarred
                        --, E.el [ Font.color Color.white, Font.size 14, E.alignRight ] (E.text ratio)
                        ]
                    , viewSnippets model filteredSnippets
                    ]
                ]
            , footer model
            ]
        ]



-- (List.map (viewSnippet model)


viewSnippets : Model -> List Book -> Element FrontendMsg
viewSnippets model filteredSnippets =
    let
        currentSnippetId =
            Maybe.map .id model.currentBook |> Maybe.withDefault "---"
    in
    E.column
        [ E.spacing 12
        , E.paddingXY 0 0
        , E.scrollbarY
        , E.width (E.px <| appWidth_ model)
        , E.height (E.px (appHeight_ model - 140))
        , Background.color Color.blueGray
        ]
        (List.map (viewSnippet model currentSnippetId) filteredSnippets)


viewSnippet : Model -> String -> Book -> Element FrontendMsg
viewSnippet model currentSnippetId datum =
    let
        borderWidth =
            if datum.id == currentSnippetId then
                Border.widthEach { bottom = 2, top = 2, left = 2, right = 2 }

            else
                Border.widthEach { bottom = 2, top = 0, left = 0, right = 0 }

        bg =
            if datum.id == currentSnippetId then
                Background.color Color.palePink

            else
                Background.color Color.white

        borderColor =
            if datum.id == currentSnippetId then
                Border.color Color.darkRed

            else
                Border.color Color.darkBlue
    in
    E.row
        [ Font.size 14
        , borderWidth
        , borderColor
        , E.height (E.px 36)
        , E.width (E.px <| appWidth_ model)
        , Events.onMouseDown (ViewContent datum)
        , bg
        , View.Utility.elementAttribute "id" "__RENDERED_TEXT__"
        ]
        [ E.row [ E.spacing 12, E.paddingEach { left = 6, right = 0, top = 0, bottom = 0 } ]
            [ E.el [] (Button.editItem datum)
            , E.column
                [ E.width (E.px <| appWidth_ model - 90)
                , E.clipY
                , E.clipX
                , E.height (E.px 36)
                , E.moveUp 3
                , E.scrollbarY
                , View.Utility.elementAttribute "line-height" "1.5"
                ]
                [ View.Utility.cssNode "markdown.css"
                , View.Utility.katexCSS
                , Markdown.toHtml [] datum.notes
                    |> E.html
                ]
            ]
        ]


viewSnippet2 : Model -> String -> Book -> Element FrontendMsg
viewSnippet2 model currentSnippetId datum =
    let
        borderWidth =
            if datum.id == currentSnippetId then
                Border.widthEach { bottom = 2, top = 2, left = 2, right = 2 }

            else
                Border.widthEach { bottom = 2, top = 0, left = 0, right = 0 }

        bg =
            if datum.id == currentSnippetId then
                Background.color Color.palePink

            else
                Background.color Color.white

        borderColor =
            if datum.id == currentSnippetId then
                Border.color Color.darkRed

            else
                Border.color Color.darkBlue
    in
    E.row
        [ Font.size 14
        , borderWidth
        , borderColor
        , E.height (E.px 36)
        , E.width (E.px <| appWidth_ model)
        , Events.onMouseDown (ViewContent datum)
        , bg
        , View.Utility.elementAttribute "id" "__RENDERED_TEXT__"
        ]
        [ E.row [ E.spacing 12, E.paddingEach { left = 6, right = 0, top = 0, bottom = 0 } ]
            [ --E.el [] (Button.editItem datum)
              E.column
                [ E.width (E.px <| appWidth_ model)
                , E.clipY
                , E.clipX
                , E.height (E.px 36)
                , E.moveUp 3
                , View.Utility.elementAttribute "line-height" "1.5"
                ]
                [ View.Utility.cssNode "markdown.css"
                , View.Utility.katexCSS
                , Markdown.toHtml [] datum.notes
                    |> E.html
                ]
            ]
        ]


viewSnippetExpanded : Model -> Element FrontendMsg
viewSnippetExpanded model =
    case model.currentBook of
        Nothing ->
            E.none

        Just snippet ->
            E.column (mainColumnStyle model)
                [ E.column
                    [ E.spacing 12
                    , E.paddingXY 0 0
                    , E.width (E.px <| appWidth_ model)
                    , E.height E.fill
                    , Background.color Color.white
                    ]
                    [ E.column
                        [ Font.size 14
                        , E.height (E.px 36)
                        , E.width (E.px <| appWidth_ model)

                        --, Events.onMouseDown (ViewContent datum)
                        , View.Utility.elementAttribute "id" "__RENDERED_TEXT__"
                        ]
                        [ E.row [ E.spacing 12, E.paddingEach { left = 6, right = 6, top = 0, bottom = 0 } ]
                            [ E.column
                                [ E.width (E.px <| appWidth_ model - 40)
                                , E.clipX
                                , E.height (E.px (appHeight_ model - 20))
                                , E.paddingEach { left = 12, right = 8, top = 0, bottom = 0 }

                                -- , E.scrollbarY
                                , Events.onMouseDown (ExpandContractItem snippet)
                                , View.Utility.elementAttribute "line-height" "1.5"
                                ]
                                [ View.Utility.cssNode "markdown.css"
                                , View.Utility.katexCSS
                                , Markdown.toHtml [] snippet.notes
                                    |> E.html
                                ]
                            ]
                        ]
                    ]
                ]


footer model =
    E.row
        [ E.spacing 12
        , E.paddingXY 0 8
        , E.height (E.px 25)
        , E.width (E.px <| appWidth_ model)
        , Font.size 14
        , E.inFront (View.AdminPopup.admin model)
        ]
        [ Button.adminPopup model
        , messageRow model
        ]


messageRow model =
    E.row
        [ E.width E.fill
        , E.height (E.px 30)
        , E.paddingXY 8 4
        , View.Style.bgGray 0.1
        , View.Style.fgGray 1.0
        ]
        [ E.text model.message ]


userHeading model =
    case model.currentUser of
        Nothing ->
            E.row
                [ E.spacing 12
                , Font.size 14
                ]
                [ Button.signIn
                , View.Input.usernameInput model
                , View.Input.passwordInput model
                ]

        Just user ->
            Button.signOut user.username


header model =
    case model.currentUser of
        Nothing ->
            notSignedInHeader model

        Just user ->
            signedInHeader model user


notSignedInHeader model =
    E.row
        [ E.spacing 12
        , Font.size 14
        ]
        [ Button.signIn
        , View.Input.usernameInput model
        , View.Input.passwordInput model
        , E.el [ E.height (E.px 31), E.paddingXY 12 3, Background.color Color.paleBlue ]
            (E.el [ E.centerY ] (E.text model.message))
        ]


signedInHeader model user =
    E.row [ E.spacing 12 ]
        [ Button.starSnippet
        , Button.new
        , Button.save
        , Button.view
        , Button.delete
        , Button.fetch
        ]


docsInfo model n =
    let
        total =
            List.length model.documents
    in
    E.el
        [ E.height (E.px 30)
        , E.width (E.px docListWidth)
        , Font.size 16
        , E.paddingXY 12 7
        , Background.color Color.paleViolet
        , Font.color Color.lightBlue
        ]
        (E.text <| "filtered/fetched = " ++ String.fromInt n ++ "/" ++ String.fromInt total)


viewDummy : Model -> Element FrontendMsg
viewDummy model =
    E.column
        [ E.paddingEach { left = 24, right = 24, top = 12, bottom = 96 }
        , Background.color Color.veryPaleBlue
        , E.width (E.px (panelWidth_ model))
        , E.height (E.px (panelHeight_ model))
        , E.centerX
        , Font.size 14
        , E.alignTop
        ]
        []



-- DIMENSIONS


searchDocPaneHeight =
    70


panelWidth_ model =
    min 600 (model.windowWidth - 100 - docListWidth)


docListWidth =
    220


appHeight_ model =
    model.windowHeight - 20


panelHeight_ model =
    appHeight_ model - 20


appWidth_ model =
    min 500 model.windowWidth


mainColumnStyle model =
    [ E.centerX
    , E.centerY
    , View.Style.bgGray 0.5
    , E.paddingXY 20 20
    , E.width (E.px (appWidth_ model + 40))
    , E.height (E.px (appHeight_ model + 40))
    ]


title : String -> Element msg
title str =
    -- E.row [ E.paddingEach { top = 0, bottom = 8, left = 0, right = 0 }, E.centerX, View.Style.fgGray 0.9 ] [ E.text str ]
    E.el [ E.paddingEach { top = 0, bottom = 0, left = 0, right = 18 }, View.Style.fgGray 0.9 ] (E.text str)
