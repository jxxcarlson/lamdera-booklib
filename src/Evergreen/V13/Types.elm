module Evergreen.V13.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Element
import Evergreen.V13.Authentication
import Evergreen.V13.Data
import Evergreen.V13.User
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


type alias Username =
    String


type alias UserInfo =
    { name : Username
    , books : Int
    , pages : Int
    , pagesRead : Int
    , pagesReadToday : Int
    , readingRate : Float
    }


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
    , userData : List UserInfo
    , currentUser : Maybe Evergreen.V13.User.User
    , inputUsername : String
    , inputPassword : String
    , readingRate : Float
    , snippetText : String
    , books : List Evergreen.V13.Data.Book
    , currentBook : Maybe Evergreen.V13.Data.Book
    , inputBookFilter : String
    , bookViewMode : BookViewMode
    , sortOrder : Evergreen.V13.Data.SortOrder
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
    , dataDict : Evergreen.V13.Data.DataDict
    , authenticationDict : Evergreen.V13.Authentication.AuthenticationDict
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
    | Edit Evergreen.V13.Data.Book
    | ViewContent Evergreen.V13.Data.Book
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Evergreen.V13.Data.Book
    | SetSortOrder Evergreen.V13.Data.SortOrder
    | SetCurrentBook (Maybe Evergreen.V13.Data.Book)
    | RandomizedOrder (List Evergreen.V13.Data.Book)
    | ExportJson
    | JsonRequested
    | JsonSelected File.File
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
    | GetAllUserData


type ToBackend
    = NoOpToBackend
    | RunTask
    | SendAllUserData
    | SaveDatum Username Evergreen.V13.Data.Book
    | SaveData Username (List Evergreen.V13.Data.Book)
    | SendUserData Username
    | UpdateDatum Username Evergreen.V13.Data.Book
    | DeleteBookFromStore Username Evergreen.V13.Data.DataId
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotAllUserData (List UserInfo)
    | GotBooks (List Evergreen.V13.Data.Book)
    | SendUser Evergreen.V13.User.User
    | SendReadingRate Float
