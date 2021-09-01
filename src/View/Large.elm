module View.Large exposing (..)

import Data exposing (Book)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Html exposing (Html)
import Markdown
import Types exposing (..)
import View.Button as Button
import View.Color as Color
import View.Input
import View.Large.ListBooks as ListBooks
import View.Popup
import View.Style
import View.Utility


type alias Model =
    FrontendModel


view : Model -> Html FrontendMsg
view model =
    E.layoutWith { options = [ E.focusStyle View.Utility.noFocus ] }
        [ View.Style.bgGray 0.2, E.clipX, E.clipY ]
        (mainColumn model)


mainColumn : Model -> Element FrontendMsg
mainColumn model =
    E.column (mainColumnStyle model)
        [ E.column [ E.spacing 6, E.width (appWidth_ 0 model), E.height (E.px (appHeight model)) ]
            [ E.row [ E.width (appWidth_ 0 model) ]
                [ title "Booklib"
                -- , E.el [ E.alignRight ] (Button.expandCollapseView model.viewMode)
                ]
            , header model
            , E.row [ E.spacing 12 ] [ lhs model, rhs model ]
            , footer model
            ]
        ]

-- https://www.hastac.org/sites/default/files/upload/images/post/books.jpg

lhs model =
    case model.currentUser of
        Nothing -> signInScreen model
        Just _ -> signedInLhs model


signInScreen model =
     E.column [ E.spacing 12, E.width (panelWidth 0 model) ]
             [ E.column [ E.spacing 12 ]
                 [
                   E.image [E.width (appWidth_ 0 model), E.height (E.px <| appHeight model - 155) ] {src = "https://www.hastac.org/sites/default/files/upload/images/post/books.jpg", description = "Library"}
                 ]
             ]


signedInLhs model =
    let
        filteredBooks =
            Data.filter (String.trim model.inputBookFilter) model.books

        totalPagesInBooks =
            List.map .pages filteredBooks |> List.sum

        totalPagesRead =
            List.map .pagesRead filteredBooks |> List.sum

        percentRead =
            100 * toFloat totalPagesRead / toFloat totalPagesInBooks |> round

        numberOfBooks =
            String.fromInt (List.length model.books)

        numberOfFilteredBooks =
            String.fromInt (List.length filteredBooks)

        ratioPages =
            "Pages: "
                ++ String.fromInt totalPagesRead
                ++ "/"
                ++ String.fromInt totalPagesInBooks
                ++ " ("
                ++ String.fromInt percentRead
                ++ "%)"

        ratioBooks =
            "Books: " ++ numberOfFilteredBooks ++ "/" ++ numberOfBooks
    in
    E.column [ E.spacing 12, E.width (panelWidth 0 model) ]
        [ E.column [ E.spacing 12 ]
            [ View.Utility.hideIf (model.currentUser == Nothing) (lhsHeader model ratioBooks ratioPages)
            , ListBooks.listBooks model filteredBooks
            ]
        ]


lhsHeader model ratioBooks ratioPages =
    E.row [ E.spacing 8, E.width (panelWidth 0 model) ]
        [ View.Input.bookFilter model (panelWidth_ -260 model)
        , Button.searchByStarred
        , Button.new
        , E.row [ E.width (E.px 200), E.spacing 24, E.paddingEach { left = 24, right = 0, top = 0, bottom = 0 } ]
            [ E.el [ Font.color Color.white, Font.size 14 ] (E.text ratioBooks)
            , View.Utility.showIf (model.appMode == ViewBooksMode)
                (E.el [ Font.color Color.white, Font.size 14 ] (E.text ratioPages))
            ]
        ]


rhs model =
    case model.appMode of
        ViewBookMode ->
            case model.currentBook of
                Nothing ->
                    E.none

                Just book ->
                    viewBook model book

        ViewBooksMode ->
            E.none

        NewBookMode ->
            E.column [ E.spacing 18, E.width (panelWidth 0 model) ]
                [ E.column [ E.spacing 18 ]
                    [ newBookHeader
                    , newBook (panelWidth_ 0 model) (appHeight model - 154) model (Data.blank model.currentTime)
                    ]
                ]

        EditBookMode ->
            case model.currentBook of
                Nothing ->
                    E.none

                Just book ->
                    E.column [ E.spacing 18, E.width (panelWidth 0 model) ]
                        [ E.column [ E.spacing 18 ]
                            [ rhsHeader model
                            , bookEditor (panelWidth_ 0 model) (appHeight model - 154) model book
                            ]
                        ]


newBook : Int -> Int -> FrontendModel -> Data.Book -> Element FrontendMsg
newBook width_ height_ model book =
    E.column [ E.spacing 18, E.width (E.px width_), E.height (E.px height_) ]
        [ E.column [ E.spacing 18 ]
            [ E.column
                [ E.width (panelWidth 0 model)
                , E.height (E.px <| appHeight model - 155)
                , E.spacing 18
                , E.alignTop
                , Background.color Color.palePink
                , E.paddingXY 12 12
                , Font.size 14
                , View.Utility.elementAttribute "line-height" "1.5"
                ]
                [ View.Input.title model 300
                , View.Input.subtitle model 300
                , View.Input.author model 300
                , View.Input.category model 300
                , View.Input.pagesRead model 300
                , View.Input.pages model 300
                ]
            ]
        ]


bookEditor : Int -> Int -> FrontendModel -> Data.Book -> Element FrontendMsg
bookEditor width_ height_ model book =
    E.column [ E.spacing 18, E.width (E.px width_), E.height (E.px height_) ]
        [ E.column [ E.spacing 18 ]
            [ E.column
                [ E.width (panelWidth 0 model)
                , E.height (E.px <| appHeight model - 155)
                , E.spacing 18
                , E.alignTop
                , Background.color Color.palePink
                , E.paddingXY 12 12
                , Font.size 14
                , View.Utility.elementAttribute "line-height" "1.5"
                ]
                [ View.Input.title model 300
                , View.Input.subtitle model 300
                , View.Input.author model 300
                , View.Input.category model 300
                , View.Input.pagesRead model 300
                , View.Input.pages model 300
                ]
            ]
        ]


viewBook model book =
    E.column [ E.width (panelWidth 0 model) ]
        [ E.column
            [ E.spacing 18
            ]
            [ rhsHeader model
            , E.column
                [ Background.color Color.white
                , E.paddingXY 12 12
                , Font.size 14
                , Events.onMouseDown (SetAppMode ViewBooksMode)
                ]
                [ E.column [ E.width (panelWidth 0 model), E.height (E.px 140), E.spacing 12 ]
                    [ E.el [ Font.bold ] (E.text book.title)
                    , E.text book.subtitle
                    , E.text ("by " ++ book.author)
                    , E.text ("Category: " ++ book.category)
                    , E.text ("Pages read: " ++ String.fromInt book.pagesRead)
                    , E.text ("Pages: " ++ String.fromInt book.pages)
                    ]
                , E.column
                    [ E.width (panelWidth 0 model)
                    , E.height (E.px <| appHeight model - 315)
                    , E.scrollbarY
                    , Font.size 14
                    , E.paddingEach { top = 18, bottom = 0, right = 0, left = 0 }
                    , View.Utility.elementAttribute "line-height" "1.5"
                    ]
                    [ E.el [ Font.bold ] (E.text "Notes")
                    , Markdown.toHtml [] book.notes
                        |> E.html
                    ]
                ]
            ]
        ]


footer model =
    E.row
        [ E.spacing 18
        , E.paddingEach { top = 20, bottom = 8, left = 0, right = 0 }
        , E.height (E.px 25)
        , E.width (appWidth_ 0 model)
        , Font.size 14
        , E.inFront (View.Popup.admin model)
        ]
        [ View.Utility.hideIf (model.currentUser == Nothing) (Button.adminPopup model)
        , View.Utility.hideIf (model.currentUser == Nothing) Button.exportJson
        , View.Utility.hideIf (model.currentUser == Nothing) Button.importJson
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


footerButtons model =
    E.row [ E.width (panelWidth 0 model), E.spacing 12 ] []


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
        [ Button.signOut user.username
        , Button.fetch
        , Button.help
        ]


newBookHeader =
    E.row [ E.spacing 12 ]
        [ Button.starSnippet
        , Button.save
        , Button.view
        , Button.delete
        ]


rhsHeader model =
    case model.appMode of
        ViewBookMode ->
            E.row [ E.spacing 12 ]
                [ Button.starSnippet
                , case model.currentBook of
                    Nothing ->
                        E.none

                    Just book ->
                        Button.editItem2 book
                , Button.save
                , Button.view
                , Button.delete
                ]

        ViewBooksMode ->
            E.row [ E.spacing 12 ]
                [ Button.starSnippet
                , case model.currentBook of
                    Nothing ->
                        E.none

                    Just snippet ->
                        Button.editItem2 snippet
                ]

        NewBookMode ->
            E.row [ E.spacing 12 ]
                [ Button.starSnippet
                , case model.currentBook of
                    Nothing ->
                        E.none

                    Just snippet ->
                        Button.editItem2 snippet
                , Button.save
                , Button.view
                , Button.delete
                ]

        EditBookMode ->
            E.row [ E.spacing 12 ]
                [ Button.starSnippet
                , case model.currentBook of
                    Nothing ->
                        E.none

                    Just snippet ->
                        Button.editItem2 snippet
                , Button.save
                , Button.view
                , Button.delete
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
        , E.width (panelWidth 0 model)
        , E.height (E.px (panelHeight_ model))
        , E.centerX
        , Font.size 14
        , E.alignTop
        ]
        []



-- DIMENSIONS


searchDocPaneHeight =
    70


docListWidth =
    220


appHeight : { a | windowHeight : number } -> number
appHeight model =
    model.windowHeight - 100


panelHeight_ model =
    appHeight model - 110


appWidth_ : Int -> { a | windowWidth : Int } -> E.Length
appWidth_ delta model =
    E.px (min 1110 model.windowWidth + delta)


panelWidth : Int -> { a | windowWidth : Int } -> E.Length
panelWidth delta model =
    E.px (panelWidth_ delta model)


panelWidth_ : Int -> { a | windowWidth : Int } -> Int
panelWidth_ delta model =
    round (min 549 (0.48 * toFloat model.windowWidth)) + delta


mainColumnStyle model =
    [ E.centerX
    , E.centerY
    , View.Style.bgGray 0.5
    , E.paddingXY 20 20
    , E.width (appWidth_ 40 model)
    , E.height (E.px (appHeight model + 40))
    ]


title : String -> Element msg
title str =
    E.row [ E.paddingEach { top = 0, bottom = 8, left = 0, right = 0 }, E.centerX, View.Style.fgGray 0.9 ] [ E.text str ]
