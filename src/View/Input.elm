module View.Input exposing
    ( author
    , newBook
    , pages
    , pagesRead
    , passwordInput
    , snippetFilter
    , subtitle
    , title
    , usernameInput
    )

import Data
import Element as E exposing (Element, px)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Types exposing (AppMode(..), FrontendModel, FrontendMsg(..))
import View.Color as Color


inputFieldTemplate : E.Length -> E.Length -> String -> (String -> msg) -> String -> Element msg
inputFieldTemplate width_ height_ default msg text =
    Input.text [ E.moveUp 5, Font.size 16, E.height height_, E.width width_ ]
        { onChange = msg
        , text = text
        , label = Input.labelHidden default
        , placeholder = Just <| Input.placeholder [ E.moveUp 5 ] (E.text default)
        }


multiLineTemplate : List (E.Attribute msg) -> E.Length -> E.Length -> String -> (String -> msg) -> String -> Element msg
multiLineTemplate attrList width_ height_ default msg text =
    Input.multiline ([ E.moveUp 5, Font.size 16, E.height height_, E.width width_, E.scrollbarY ] ++ attrList)
        { onChange = msg
        , text = text
        , label = Input.labelHidden default
        , placeholder = Just <| Input.placeholder [ E.moveUp 5 ] (E.text default)
        , spellcheck = False
        }


passwordTemplate : E.Length -> String -> (String -> msg) -> String -> Element msg
passwordTemplate width_ default msg text =
    Input.currentPassword [ E.moveUp 5, Font.size 16, E.height (px 33), E.width width_ ]
        { onChange = msg
        , text = text
        , label = Input.labelHidden default
        , placeholder = Just <| Input.placeholder [ E.moveUp 5 ] (E.text default)
        , show = False
        }


usernameInput model =
    inputFieldTemplate (E.px 120) (E.px 33) "Username" InputUsername model.inputUsername


snippetFilter model width_ =
    inputFieldTemplate (E.px width_) (E.px 33) "Filter ..." InputSnippetFilter model.inputBookFilter


title : FrontendModel -> Int -> Element FrontendMsg
title model width_ =
    inputFieldTemplate (E.px width_) (E.px 33) "Title" InputTitle model.inputTitle


subtitle : FrontendModel -> Int -> Element FrontendMsg
subtitle model width_ =
    inputFieldTemplate (E.px width_) (E.px 33) "Subtitle" InputSubtitle model.inputSubtitle


author : FrontendModel -> Int -> Element FrontendMsg
author model width_ =
    inputFieldTemplate (E.px width_) (E.px 33) "Author" InputAuthor model.inputAuthor


pagesRead : FrontendModel -> Int -> Element FrontendMsg
pagesRead model width_ =
    inputFieldTemplate (E.px width_) (E.px 33) "Pages read" InputPagesRead model.inputPagesRead


pages : FrontendModel -> Int -> Element FrontendMsg
pages model width_ =
    inputFieldTemplate (E.px width_) (E.px 33) "Pages" InputPages model.inputPages


newBook : Int -> Int -> FrontendModel -> Element FrontendMsg
newBook width_ height_ model =
    E.text "New Book"



--in
--multiLineTemplate attrs (E.px width_) (E.px height_) "Snippet" InputSnippet text_


viewNotes : Int -> Int -> Data.Book -> Element FrontendMsg
viewNotes height_ width_ book =
    E.column
        [ E.height (px height_)
        , E.width (px width_)
        , E.scrollbarY
        ]
        [ E.text book.notes ]



--multiLineTemplate attrList width_ height_ default msg text =
--    Input.multiline ([ E.moveUp 5, Font.size 16, E.height height_, E.width width_, E.scrollbarY ] ++ attrList)
--        { onChange = msg
--        , text = text
--        , label = Input.labelHidden default
--        , placeholder = Just <| Input.placeholder [ E.moveUp 5 ] (E.text default)
--        , spellcheck = False
--        }


passwordInput model =
    passwordTemplate (E.px 120) "Password" InputPassword model.inputPassword
