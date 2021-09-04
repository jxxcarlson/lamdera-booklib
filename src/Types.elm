module Types exposing (..)

import Authentication exposing (AuthenticationDict)
import Browser exposing (UrlRequest)
import Browser.Dom as Dom
import Browser.Navigation exposing (Key)
import Data exposing (Book, DataDict, DataId, SortOrder)
import Element
import File exposing (File)
import Http
import Markdown
import Random
import Time
import Url exposing (Url)
import User exposing (User)


type alias Username =
    String


type alias FrontendModel =
    { key : Key
    , url : Url
    , message : String
    , currentTime : Time.Posix
    , randomSeed : Random.Seed
    , appMode : AppMode

    -- ADMIN
    , userData : List UserInfo

    -- USER
    , currentUser : Maybe User
    , inputUsername : String
    , inputPassword : String
    , readingRate : Float

    -- DATA
    , snippetText : String
    , books : List Book
    , currentBook : Maybe Book
    , inputBookFilter : String
    , bookViewMode : BookViewMode
    , sortOrder : SortOrder

    -- INPUT
    , inputTitle : String
    , inputSubtitle : String
    , inputAuthor : String
    , inputCategory : String
    , inputPages : String
    , inputPagesRead : String
    , inputNotes : String

    -- UI
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , viewMode : ViewMode
    , device : Element.DeviceClass
    , bookViewState : BookViewState
    }


type alias BookViewState =
    { bookId : Maybe String, clicks : Int }


type ViewMode
    = SmallView
    | LargeView


type BookViewMode
    = SnippetExpanded
    | SnippetCollapsed


type AppMode
    = ViewBooksMode
    | ViewBookMode
    | NewBookMode
    | EditBookMode
    | ViewAboutMode


type PopupWindow
    = AdminPopup


type PopupStatus
    = PopupOpen PopupWindow
    | PopupClosed


type alias BackendModel =
    { message : String

    -- SYSTEM
    , randomSeed : Random.Seed
    , randomAtmosphericInt : Maybe Int
    , currentTime : Time.Posix

    -- DATA
    , dataDict : DataDict

    -- USER
    , authenticationDict : AuthenticationDict
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GotViewport Dom.Viewport
    | NoOpFrontendMsg
    | FETick Time.Posix
    | GotAtomsphericRandomNumberFE (Result Http.Error String)
      -- UI
    | GotNewWindowDimensions Int Int
    | ChangePopupStatus PopupStatus
      -- USER
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
      -- DATA
    | InputSnippet String
    | SearchBy String
    | StarSnippet
    | New
    | Save
    | Fetch
    | About
    | Close
    | Edit Book
    | ViewContent Book
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Book
    | SetSortOrder SortOrder
    | SetCurrentBook (Maybe Book)
    | RandomizedOrder (List Book)
    | ExportJson
    | JsonRequested
    | JsonSelected File
    | JsonLoaded String
      --
    | InputTitle String
    | InputSubtitle String
    | InputAuthor String
    | InputCategory String
    | InputPages String
    | InputPagesRead String
    | InputNotes String
      -- UI
    | ExpandContractView
    | SetAppMode AppMode
      -- ADMIN
    | AdminRunTask
    | GetAllUserData


type ToBackend
    = NoOpToBackend
      -- ADMIN
    | RunTask
    | SendAllUserData
      -- DATA
    | SaveDatum Username Book
    | SaveData Username (List Book)
    | SendUserData Username
    | UpdateDatum Username Book
    | DeleteBookFromStore Username DataId
      -- USER
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type alias UserInfo =
    { name : Username, books : Int, pages : Int, pagesRead : Int, pagesReadToday : Int, readingRate : Float }


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
      -- ADMIN
    | GotAllUserData (List UserInfo)
      -- DATA
    | GotBooks (List Book)
      -- USER
    | SendUser User
    | SendReadingRate Float


type ExtendedInteger
    = Finite Int
    | Infinity
