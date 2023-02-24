module Frontend exposing (..)

import Authentication
import Backend.Backup
import Backend.RestorePrevious
import Browser exposing (UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Data
import Element
import File exposing (File)
import File.Select as Select
import Frontend.Cmd
import Frontend.Codec
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
import Util
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
      , xmode = XA

      -- ADMIN
      , userData = []

      -- USER
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
      , sortOrder = Data.SortByMostRecent
      , pagesRead = 0
      , pagesReadToday = 0
      , readingRate = 0

      -- USER
      , currentUser = Nothing
      , inputUsername = ""
      , inputPassword = ""
      , viewMode = LargeView

      -- INPUT
      , inputTitle = ""
      , inputSubtitle = ""
      , inputAuthor = ""
      , inputCategory = ""
      , inputPages = ""
      , inputPagesRead = ""
      , inputNotes = ""
      , bookViewState = { bookId = Nothing, clicks = 0 }
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
            let
                username =
                    Maybe.map .username model.currentUser |> Maybe.withDefault "nobody"

                m =
                    modBy 4 (Util.stringToInt username)

                s =
                    modBy 60 (Util.stringToInt username)

                cmd =
                    -- If the time is (m + 2) minutes and s seconds after 03:00:00 UTC,
                    -- then send a message to the backend to get user data.
                    -- The m and s provide some variation based on username so that
                    -- the backend does not received too many requests at once.
                    -- This is no doubt overkill, but it is a fun exercise.
                    -- Note that the 'pagesReadToday field is set to zero at 03:00:00 UTC
                    -- and that the new reading rate is computed at this time also.
                    if Util.isUTCTime 5 (m + 2) s time then
                        sendToBackend (SendUserData username)

                    else
                        Cmd.none
            in
            ( { model | currentTime = time }, cmd )

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
            let
                cmd =
                    if status == PopupOpen AdminPopup then
                        sendToBackend SendAllUserData

                    else
                        Cmd.none
            in
            ( { model | popupStatus = status }, cmd )

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

        SetCurrentBook maybeBook ->
            case maybeBook of
                Nothing ->
                    ( model, Cmd.none )

                Just book ->
                    let
                        oldBookViewState =
                            model.bookViewState

                        newBookViewState =
                            if oldBookViewState.bookId == Just book.id then
                                { oldBookViewState | clicks = modBy 3 (1 + model.bookViewState.clicks) }

                            else
                                { oldBookViewState | bookId = Just book.id, clicks = 0 }

                        appMode =
                            case newBookViewState.clicks of
                                0 ->
                                    EditBookMode

                                1 ->
                                    ViewBookMode

                                _ ->
                                    ViewBooksMode
                    in
                    if appMode == EditBookMode then
                        ( { model
                            | currentBook = Just book
                            , message = "Editing " ++ book.title
                            , inputTitle = book.title
                            , inputSubtitle = book.subtitle
                            , inputAuthor = book.author
                            , inputCategory = book.category
                            , inputPagesRead = String.fromInt book.pagesRead
                            , inputPages = String.fromInt book.pages
                            , appMode = appMode
                            , bookViewState = newBookViewState
                          }
                        , Cmd.none
                        )

                    else
                        ( { model | currentBook = Just book, appMode = appMode, bookViewState = newBookViewState }, Cmd.none )

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

        InputCategory str ->
            ( { model | inputCategory = str }, Cmd.none )

        InputPages str ->
            ( { model | inputPages = str }, Cmd.none )

        InputPagesRead str ->
            ( { model | inputPagesRead = str }, Cmd.none )

        InputNotes str ->
            ( { model | inputNotes = str }, Cmd.none )

        About ->
            ( { model | currentBook = Nothing, appMode = ViewAboutMode }, Cmd.none )

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
                            let
                                { token, seed } =
                                    Token.get model.randomSeed

                                blank =
                                    Data.blank model.currentTime

                                newBook =
                                    { blank
                                        | title = model.inputTitle
                                        , id = token
                                        , subtitle = model.inputSubtitle
                                        , author = model.inputAuthor
                                        , pagesRead = String.toInt model.inputPagesRead |> Maybe.withDefault 0
                                        , pages = String.toInt model.inputPages |> Maybe.withDefault 0
                                        , category = model.inputCategory
                                        , creationDate = model.currentTime
                                        , modificationDate = model.currentTime
                                        , notes = model.inputNotes
                                    }

                                newBooks =
                                    newBook :: model.books
                            in
                            ( { model
                                | books = newBooks
                                , currentBook = Just newBook
                                , appMode = ViewBooksMode
                                , randomSeed = seed
                              }
                            , sendToBackend (SaveDatum user.username newBook)
                            )

                        ViewAboutMode ->
                            ( model, Cmd.none )

                        EditBookMode ->
                            case model.currentBook of
                                Nothing ->
                                    ( model, Cmd.none )

                                Just book ->
                                    let
                                        pagesRead =
                                            case String.toInt model.inputPagesRead of
                                                Nothing ->
                                                    book.pagesRead

                                                Just k ->
                                                    k

                                        pages =
                                            case String.toInt model.inputPages of
                                                Nothing ->
                                                    book.pages

                                                Just k ->
                                                    k

                                        newBook =
                                            { book
                                                | title = model.inputTitle
                                                , subtitle = model.inputSubtitle
                                                , author = model.inputAuthor
                                                , category = model.inputCategory
                                                , pagesRead = pagesRead
                                                , pages = pages
                                                , pagesReadToday = pagesRead - book.pagesRead + book.pagesReadToday
                                                , modificationDate = model.currentTime
                                                , notes = model.inputNotes
                                            }

                                        newBooks =
                                            List.Extra.setIf (\b -> b.id == newBook.id) newBook model.books
                                    in
                                    ( { model
                                        | books = newBooks
                                        , currentBook = Just newBook
                                        , appMode = ViewBooksMode
                                      }
                                    , sendToBackend (UpdateDatum user (pagesRead - book.pagesRead) newBook)
                                    )

        Close ->
            ( { model | appMode = ViewBooksMode, snippetText = "" }, Cmd.none )

        Delete ->
            case model.currentBook of
                Nothing ->
                    ( model, Cmd.none )

                Just book ->
                    ( { model
                        | currentBook = Nothing
                        , snippetText = ""
                        , appMode = ViewBooksMode
                        , books = List.filter (\snip -> snip.id /= book.id) model.books
                      }
                    , sendToBackend (DeleteBookFromStore book.username book.id)
                    )

        Edit book ->
            ( { model
                | message = "Editing " ++ book.title
                , inputTitle = book.title
                , inputSubtitle = book.subtitle
                , inputAuthor = book.author
                , inputCategory = book.category
                , inputPagesRead = String.fromInt book.pagesRead
                , inputPages = String.fromInt book.pages
                , inputNotes = book.notes
                , appMode = EditBookMode
              }
            , Cmd.none
            )

        New ->
            ( { model
                | appMode = NewBookMode
                , currentBook = Just (Data.blank model.currentTime)
                , inputTitle = ""
                , inputSubtitle = ""
                , inputAuthor = ""
                , inputCategory = ""
                , inputPages = ""
                , inputPagesRead = ""
                , inputNotes = ""
                , message = "New book started"
              }
            , Cmd.none
            )

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

        JsonRequested jsonRequestType ->
            ( model, Select.file [ "text/json" ] (JsonSelected jsonRequestType) )

        JsonSelected jsonRequestType file ->
            case jsonRequestType of
                BackupOne ->
                    ( model, Task.perform (JsonLoaded jsonRequestType) (File.toString file) )

                BackupAll ->
                    ( model, Task.perform (JsonLoaded jsonRequestType) (File.toString file) )

        JsonLoaded jsonRequestType jsonImport ->
            case jsonRequestType of
                BackupOne ->
                    case model.currentUser of
                        Nothing ->
                            ( { model | message = "Cannot import data without a signed-in user" }, Cmd.none )

                        Just user ->
                            case Frontend.Codec.decodeSpecialData user.username jsonImport of
                                Err _ ->
                                    ( { model | message = "Data read: " ++ (String.fromInt <| String.length jsonImport) ++ ", error importing books" }, Cmd.none )

                                Ok books ->
                                    ( { model | books = books ++ model.books, message = "imported: " ++ (String.fromInt <| List.length books) }
                                    , sendToBackend (SaveData user.username books)
                                    )

                BackupAll ->
                    case Backend.RestorePrevious.decodeBackup jsonImport of
                        Err _ ->
                            ( { model | message = "Error decoding backup" }, Cmd.none )

                        Ok backendModel ->
                            ( { model | message = "restoring backup ..." }, sendToBackend (RestoreBackup backendModel) )

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

        GetAllUserData ->
            ( model, sendToBackend SendAllUserData )

        DownloadBackup ->
            ( model, sendToBackend EncodeBackendModel )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        -- ADMIN
        GotAllUserData userData ->
            ( { model | userData = userData }, Cmd.none )

        GotBackup str ->
            ( model, Frontend.Cmd.downloadBackup str )

        -- DATA
        GotData dataFile ->
            let
                books =
                    List.sortBy (\snip -> -(Time.posixToMillis snip.creationDate)) dataFile.data

                currentBook =
                    case List.head books of
                        Nothing ->
                            Nothing

                        Just snippet ->
                            Just snippet
            in
            ( { model
                | books = books
                , currentBook = currentBook
                , pagesRead = dataFile.pagesRead
                , pagesReadToday = dataFile.pagesReadToday
                , readingRate = dataFile.readingRate
              }
            , Cmd.none
            )

        -- USER
        SendUser user ->
            ( { model | currentUser = Just user, currentBook = Nothing }, Cmd.none )

        SendReadingRate rate ->
            ( { model | readingRate = rate }, Cmd.none )

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
