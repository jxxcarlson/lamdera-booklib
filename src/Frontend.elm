module Frontend exposing (..)

import Authentication
import Browser exposing (UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Codec
import Data
import Element
import File exposing (File)
import File.Select as Select
import Frontend.Cmd
import Frontend.Update
import Html exposing (Html)
import Lamdera exposing (sendToBackend)
import List.Extra
import Random
import Random.List
import Task
import Time
import Token
import Types exposing (..)
import Url exposing (Url)
import View.Large
import View.Small


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\w h -> GotNewWindowDimensions w h)
        , Time.every 1000 FETick
        ]


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , url = url
      , message = "Welcome!"
      , currentTime = Time.millisToPosix 0
      , randomSeed = Random.initialSeed 1234
      , appMode = ViewBooksMode

      -- ADMIN
      , users = []

      -- UI
      , windowWidth = 1200
      , windowHeight = 900
      , popupStatus = PopupClosed
      , device = Element.Phone

      -- DATA
      , snippetText = ""
      , books = []
      , currentBook = Nothing
      , inputBookFilter = ""
      , bookViewMode = SnippetCollapsed
      , sortOrder = Data.NormalSortOrder

      -- USER
      , currentUser = Nothing
      , inputUsername = ""
      , inputPassword = ""
      , viewMode = LargeView

      -- INPUT
      , inputTitle = ""
      , inputSubtitle = ""
      , inputAuthor = ""
      , inputPages = ""
      , inputPagesRead = ""
      , inputNotes = ""
      }
    , Cmd.batch [ Frontend.Cmd.setupWindow, Frontend.Cmd.getRandomNumberFE ]
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Cmd.none )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

        FETick time ->
            ( { model | currentTime = time }, Cmd.none )

        GotAtomsphericRandomNumberFE result ->
            case result of
                Ok str ->
                    case String.toInt (String.trim str) of
                        Nothing ->
                            ( { model | message = "Failed to get atmospheric random number" }, Cmd.none )

                        Just rn ->
                            let
                                newRandomSeed =
                                    Random.initialSeed rn
                            in
                            ( { model
                                | randomSeed = newRandomSeed
                              }
                            , Cmd.none
                            )

                Err _ ->
                    ( model, Cmd.none )

        -- UI
        GotNewWindowDimensions w h ->
            ( { model | windowWidth = w, windowHeight = h }, Cmd.none )

        ChangePopupStatus status ->
            ( { model | popupStatus = status }, Cmd.none )

        GotViewport vp ->
            Frontend.Update.updateWithViewport vp model

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        -- USER
        SignIn ->
            if String.length model.inputPassword >= 8 then
                ( { model | currentBook = Nothing }
                , sendToBackend (SignInOrSignUp model.inputUsername (Authentication.encryptForTransit model.inputPassword))
                )

            else
                ( { model | message = "Password must be at least 8 letters long.", currentBook = Nothing }, Cmd.none )

        InputUsername str ->
            ( { model | inputUsername = str }, Cmd.none )

        InputPassword str ->
            ( { model | inputPassword = str }, Cmd.none )

        SignOut ->
            ( { model
                | currentUser = Nothing
                , message = "Signed out"
                , inputUsername = ""
                , inputPassword = ""
                , snippetText = ""
                , books = []
                , currentBook = Nothing
                , appMode = ViewBooksMode
              }
            , Cmd.none
            )

        -- DATA
        InputSnippet str ->
            ( { model | snippetText = str }, Cmd.none )

        InputSnippetFilter str ->
            ( { model | inputBookFilter = str }, Cmd.none )

        SearchBy str ->
            let
                inputSnippetFilter =
                    if str == "★" then
                        "★" ++ model.inputBookFilter

                    else
                        str
            in
            ( { model | inputBookFilter = inputSnippetFilter }, Cmd.none )

        StarSnippet ->
            let
                newSnippetText =
                    if String.slice 0 1 model.snippetText == "★" then
                        "★" ++ model.snippetText

                    else
                        "★ " ++ model.snippetText
            in
            ( { model | snippetText = newSnippetText }, Cmd.none )

        RandomizedOrder snippets_ ->
            ( { model | books = snippets_ }, Cmd.none )

        SetSortOrder sortOrder ->
            ( { model | sortOrder = sortOrder }, Cmd.none )

        SetCurrentBook book ->
            ( { model | currentBook = book, appMode = ViewBookMode }, Cmd.none )

        Fetch ->
            case model.currentUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    ( model, sendToBackend (SendUserData user.username) )

        -- INPUT
        InputTitle str ->
            ( { model | inputTitle = str }, Cmd.none )

        InputSubtitle str ->
            ( { model | inputSubtitle = str }, Cmd.none )

        InputAuthor str ->
            ( { model | inputAuthor = str }, Cmd.none )

        InputPages str ->
            ( { model | inputPages = str }, Cmd.none )

        InputPagesRead str ->
            ( { model | inputPagesRead = str }, Cmd.none )

        InputNotes str ->
            ( { model | inputNotes = str }, Cmd.none )

        Help ->
            ( { model | currentBook = Nothing, appMode = ViewBooksMode }, Cmd.none )

        Save ->
            case model.currentUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    case model.appMode of
                        ViewBookMode ->
                            ( model, Cmd.none )

                        ViewBooksMode ->
                            ( model, Cmd.none )

                        NewBookMode ->
                            case model.currentBook of
                                Nothing ->
                                    ( model, Cmd.none )

                                Just book ->
                                    let
                                        { token, seed } =
                                            Token.get model.randomSeed

                                        newSnippet =
                                            { book
                                                | title = model.snippetText |> Data.fixUrls
                                                , id = token
                                            }

                                        newSnippets =
                                            newSnippet :: model.books
                                    in
                                    ( { model
                                        | books = newSnippets
                                        , currentBook = Just newSnippet
                                        , appMode = ViewBooksMode
                                        , snippetText = newSnippet.title
                                        , randomSeed = seed
                                      }
                                    , sendToBackend (SaveDatum user.username newSnippet)
                                    )

                        EditBookMode ->
                            case model.currentBook of
                                Nothing ->
                                    ( model, Cmd.none )

                                Just snippet ->
                                    let
                                        newSnippet =
                                            { snippet
                                                | title = "NEW"
                                            }

                                        newSnippets =
                                            List.Extra.setIf (\snip -> snip.id == newSnippet.id) newSnippet model.books
                                    in
                                    ( { model
                                        | books = newSnippets
                                        , currentBook = Just newSnippet
                                        , appMode = ViewBooksMode
                                        , snippetText = newSnippet.title
                                      }
                                    , sendToBackend (UpdateDatum user.username newSnippet)
                                    )

        Close ->
            ( { model | appMode = ViewBooksMode, snippetText = "" }, Cmd.none )

        Delete ->
            case model.currentBook of
                Nothing ->
                    ( model, Cmd.none )

                Just snippet ->
                    ( { model
                        | currentBook = Nothing
                        , snippetText = ""
                        , appMode = ViewBooksMode
                        , books = List.filter (\snip -> snip.id /= snippet.id) model.books
                      }
                    , sendToBackend (DeleteSnippetFromStore snippet.username snippet.id)
                    )

        Edit book ->
            ( { model
                | message = "Editing " ++ book.title
                , inputTitle = book.title
                , inputSubtitle = book.subtitle
                , inputAuthor = book.author
                , inputPagesRead = String.fromInt book.pagesRead
                , inputPages = String.fromInt book.pages
                , appMode = EditBookMode
              }
            , Cmd.none
            )

        New ->
            ( { model | appMode = NewBookMode, message = "New book started" }, Cmd.none )

        ViewContent datum ->
            ( { model | currentBook = Just datum, appMode = ViewBooksMode, bookViewMode = SnippetExpanded }, Cmd.none )

        ExpandContractItem datum ->
            let
                toggleViewMode mode =
                    case mode of
                        SnippetExpanded ->
                            SnippetCollapsed

                        SnippetCollapsed ->
                            SnippetExpanded
            in
            ( { model
                | currentBook = Just datum
                , bookViewMode = toggleViewMode model.bookViewMode
              }
            , Cmd.none
            )

        JsonRequested ->
            ( model, Select.file [ "text/json" ] JsonSelected )

        JsonSelected file ->
            ( model, Task.perform JsonLoaded (File.toString file) )

        JsonLoaded jsonImport ->
            case Codec.decodeData jsonImport of
                Err _ ->
                    ( { model | message = "Error importing snippets" }, Cmd.none )

                Ok snippets ->
                    ( { model
                        | books = snippets
                        , message = "imported: " ++ (String.fromInt <| String.length jsonImport)
                      }
                    , Cmd.none
                    )

        ExportJson ->
            ( model, Frontend.Cmd.exportJson model )

        -- UI
        SetAppMode appMode ->
            ( { model | appMode = appMode }, Cmd.none )

        ExpandContractView ->
            let
                newViewMode =
                    case model.viewMode of
                        SmallView ->
                            LargeView

                        LargeView ->
                            SmallView
            in
            ( { model | viewMode = newViewMode }, Cmd.none )

        -- ADMIN
        AdminRunTask ->
            ( model, sendToBackend RunTask )

        GetUsers ->
            ( model, sendToBackend SendUsers )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        -- ADMIN
        GotUsers users ->
            ( { model | users = users }, Cmd.none )

        -- DATA
        GotUserData dataList ->
            let
                snippets =
                    List.sortBy (\snip -> -(Time.posixToMillis snip.creationDate)) dataList

                currentSnippet =
                    case List.head snippets of
                        Nothing ->
                            Nothing

                        Just snippet ->
                            Just snippet
            in
            ( { model | books = Data.bookTestData, currentBook = currentSnippet }, Cmd.none )

        -- USER
        SendUser user ->
            ( { model | currentUser = Just user, currentBook = Nothing }, Cmd.none )

        SendMessage message ->
            ( { model | message = message }, Cmd.none )


view : Model -> { title : String, body : List (Html.Html FrontendMsg) }
view model =
    { title = "Booklib"
    , body =
        case model.viewMode of
            SmallView ->
                [ View.Small.view model ]

            LargeView ->
                [ View.Large.view model ]
    }
