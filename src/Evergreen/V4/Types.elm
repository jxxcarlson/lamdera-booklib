module Evergreen.V4.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Element
import Evergreen.V4.Authentication
import Evergreen.V4.Data
import Evergreen.V4.User
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
    , users : List Evergreen.V4.User.User
    , currentUser : Maybe Evergreen.V4.User.User
    , inputUsername : String
    , inputPassword : String
    , snippetText : String
    , books : List Evergreen.V4.Data.Book
    , currentBook : Maybe Evergreen.V4.Data.Book
    , inputBookFilter : String
    , bookViewMode : BookViewMode
    , sortOrder : Evergreen.V4.Data.SortOrder
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
    , dataDict : Evergreen.V4.Data.DataDict
    , authenticationDict : Evergreen.V4.Authentication.AuthenticationDict
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
    | Help
    | Close
    | Edit Evergreen.V4.Data.Book
    | ViewContent Evergreen.V4.Data.Book
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Evergreen.V4.Data.Book
    | SetSortOrder Evergreen.V4.Data.SortOrder
    | SetCurrentBook (Maybe Evergreen.V4.Data.Book)
    | RandomizedOrder (List Evergreen.V4.Data.Book)
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
    | SaveDatum Username Evergreen.V4.Data.Book
    | SaveData Username (List Evergreen.V4.Data.Book)
    | SendUserData Username
    | UpdateDatum Username Evergreen.V4.Data.Book
    | DeleteSnippetFromStore Username Evergreen.V4.Data.DataId
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V4.User.User)
    | GotBooks (List Evergreen.V4.Data.Book)
    | SendUser Evergreen.V4.User.User
