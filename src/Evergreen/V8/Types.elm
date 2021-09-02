module Evergreen.V8.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Element
import Evergreen.V8.Authentication
import Evergreen.V8.Data
import Evergreen.V8.User
import File
import Http
import Random
import Time
import Url


type AppMode
    = ViewBooksMode
    | ViewBookMode
    | NewBookMode
    | EditBookMode
    | ViewAboutMode


type BookViewMode
    = SnippetExpanded
    | SnippetCollapsed


type PopupWindow
    = AdminPopup


type PopupStatus
    = PopupOpen PopupWindow
    | PopupClosed


type ViewMode
    = SmallView
    | LargeView


type alias BookViewState =
    { bookId : Maybe String
    , clicks : Int
    }


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , message : String
    , currentTime : Time.Posix
    , randomSeed : Random.Seed
    , appMode : AppMode
    , users : List Evergreen.V8.User.User
    , currentUser : Maybe Evergreen.V8.User.User
    , inputUsername : String
    , inputPassword : String
    , snippetText : String
    , books : List Evergreen.V8.Data.Book
    , currentBook : Maybe Evergreen.V8.Data.Book
    , inputBookFilter : String
    , bookViewMode : BookViewMode
    , sortOrder : Evergreen.V8.Data.SortOrder
    , inputTitle : String
    , inputSubtitle : String
    , inputAuthor : String
    , inputCategory : String
    , inputPages : String
    , inputPagesRead : String
    , inputNotes : String
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , viewMode : ViewMode
    , device : Element.DeviceClass
    , bookViewState : BookViewState
    }


type alias BackendModel =
    { message : String
    , randomSeed : Random.Seed
    , randomAtmosphericInt : Maybe Int
    , currentTime : Time.Posix
    , dataDict : Evergreen.V8.Data.DataDict
    , authenticationDict : Evergreen.V8.Authentication.AuthenticationDict
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotViewport Browser.Dom.Viewport
    | NoOpFrontendMsg
    | FETick Time.Posix
    | GotAtomsphericRandomNumberFE (Result Http.Error String)
    | GotNewWindowDimensions Int Int
    | ChangePopupStatus PopupStatus
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
    | InputSnippet String
    | SearchBy String
    | StarSnippet
    | New
    | Save
    | Fetch
    | About
    | Close
    | Edit Evergreen.V8.Data.Book
    | ViewContent Evergreen.V8.Data.Book
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Evergreen.V8.Data.Book
    | SetSortOrder Evergreen.V8.Data.SortOrder
    | SetCurrentBook (Maybe Evergreen.V8.Data.Book)
    | RandomizedOrder (List Evergreen.V8.Data.Book)
    | ExportJson
    | JsonRequested
    | JsonSelected File
    | JsonLoaded String
    | InputTitle String
    | InputSubtitle String
    | InputAuthor String
    | InputCategory String
    | InputPages String
    | InputPagesRead String
    | InputNotes String
    | ExpandContractView
    | SetAppMode AppMode
    | AdminRunTask
    | GetUsers


type alias Username =
    String


type ToBackend
    = NoOpToBackend
    | RunTask
    | SendUsers
    | SaveDatum Username Evergreen.V8.Data.Book
    | SaveData Username (List Evergreen.V8.Data.Book)
    | SendUserData Username
    | UpdateDatum Username Evergreen.V8.Data.Book
    | DeleteBookFromStore Username Evergreen.V8.Data.DataId
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V8.User.User)
    | GotBooks (List Evergreen.V8.Data.Book)
    | SendUser Evergreen.V8.User.User
