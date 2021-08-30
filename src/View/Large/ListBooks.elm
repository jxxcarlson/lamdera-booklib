module View.Large.ListBooks exposing (..)

import Data
import Element
    exposing
        ( Element
        , alignRight
        , clipX
        , el
        , height
        , moveRight
        , paddingXY
        , px
        , scrollbarY
        , text
        )
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Types exposing (AppMode(..), FrontendModel, FrontendMsg(..))
import View.Common.Indicator as Indicator
import View.Config as Config
import View.Style as Style


type alias Model =
    FrontendModel


listBooks : Model -> Element FrontendMsg
listBooks model =
    let
        nBooks =
            List.length model.books
    in
    Element.table
        [ Element.centerX
        , Font.size 13
        , Element.spacing 10
        , paddingXY 18 18
        , scrollbarY
        , height (px (model.windowHeight - Config.verticalMargin))
        , Background.color Style.charcoal
        , Font.color Style.white
        , clipX
        ]
        { data = Data.sortBooks model.sortOrder (List.indexedMap Tuple.pair model.books)
        , columns =
            [ { header = Element.el (Style.tableHeading ++ [ clipX ]) (indexButton model)
              , width = px 20
              , view =
                    \p ->
                        el [] (text <| String.fromInt <| nBooks - Tuple.first p)
              }
            , { header = Element.el (Style.tableHeading ++ [ clipX ]) (text "S")
              , width = px 20
              , view =
                    \p ->
                        displayShareStatus (Tuple.second p)
              }
            , { header = Element.el (Style.tableHeading ++ [ clipX ]) (titleHeadingButton model)
              , width = px 200
              , view =
                    \p ->
                        titleButton (Tuple.second p) model.currentBook
              }
            , { header = Element.el Style.tableHeading (authorButton model)
              , width = px 150
              , view =
                    \p ->
                        el [ clipX ] (Element.text (Tuple.second p).author)
              }
            , { header = Element.el Style.tableHeading (categoryButton model)
              , width = px 150
              , view =
                    \p ->
                        el [ clipX ] (Element.text (Tuple.second p).category)
              }
            , { header = Element.el Style.tableHeading (Element.text "")
              , width = px 110
              , view =
                    \p ->
                        Element.el [] (Indicator.indicator 100 10 "orange" (pageRatio (Tuple.second p)))
              }
            , { header = Element.el Style.tableHeading (el [ moveRight 16 ] (Element.text "Progress"))
              , width = px 80
              , view =
                    \p ->
                        el [] (el [ alignRight, paddingXY 8 0 ] (Element.text (pageInfo (Tuple.second p))))
              }
            , { header = Element.el Style.tableHeading (el [ moveRight 9 ] (Element.text "%%"))
              , width = px 40
              , view =
                    \p ->
                        el [] (el [ alignRight, paddingXY 8 0 ] (pageInfo2Button (Tuple.second p)))
              }
            ]
        }


indexButton : Model -> Element FrontendMsg
indexButton model =
    Input.button (Style.titleButton2 (model.sortOrder == Data.NormalSortOrder))
        { onPress = Just (SetSortOrder Data.NormalSortOrder)
        , label = Element.text "N"
        }


displayShareStatus book =
    case book.public of
        True ->
            el [ Font.color Style.white ] (text "s")

        False ->
            el [ Font.color Style.white, Font.bold ] (text "•")


titleHeadingButton : Model -> Element FrontendMsg
titleHeadingButton model =
    Input.button (Style.titleButton2 (model.sortOrder == Data.SortByTitle))
        { onPress = Just (SetSortOrder Data.SortByTitle)
        , label = Element.text "Title"
        }


titleButton book maybeCurrentBook =
    let
        highlighted =
            case maybeCurrentBook of
                Nothing ->
                    False

                Just currentBook ->
                    currentBook.id == book.id

        title =
            if book.title == "" then
                "Untitled"

            else
                book.title
    in
    Input.button (Style.titleButton highlighted)
        { onPress = Just (SetCurrentBook (Just book))
        , label = Element.text title
        }


authorButton : Model -> Element FrontendMsg
authorButton model =
    Input.button (Style.titleButton2 (model.sortOrder == Data.SortByAuthor))
        { onPress = Just (SetSortOrder Data.SortByAuthor)
        , label = Element.text "Author"
        }


categoryButton : Model -> Element FrontendMsg
categoryButton model =
    Input.button (Style.titleButton2 (model.sortOrder == Data.SortByCategory))
        { onPress = Just (SetSortOrder Data.SortByCategory)
        , label = Element.text "Category"
        }


pageInfo2Button : Data.Book -> Element FrontendMsg
pageInfo2Button book =
    Input.button (Style.titleButton2 True)
        { onPress = Just (Edit book)
        , label = Element.text (pageInfo2 book)
        }


pageRatio book =
    toFloat book.pagesRead / toFloat book.pages


pageInfo book =
    String.fromInt book.pagesRead ++ "/" ++ String.fromInt book.pages


pageInfo2 book =
    (String.fromInt <| Basics.round <| 100 * Basics.toFloat book.pagesRead / Basics.toFloat book.pages) ++ "%"
