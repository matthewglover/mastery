module Main exposing (..)

import Backend
import Debug
import Header
import Healthcheck.Healthcheck as Healthcheck
import Html exposing (Html)
import LandingPage.LandingPage as LandingPage
import LandingPage.State exposing (Model)
import LoginPage.LoginPage as LoginPage exposing (..)
import Messages exposing (Auth(..), Msg(..))
import Navigation exposing (..)
import View.PersonalPath exposing (view)
import Data.PersonalPath
import Routing exposing (Route(..), pageToUrl, parseLocation)


type alias Config =
    { baseUrl : String
    , buildTime : String
    , commit : String
    }


type alias AppModel =
    { route : Routing.Route
    , landing : LandingPage.State.Model
    , healthcheck : Healthcheck.Model
    , login : Auth
    , path : Maybe Data.PersonalPath.Path
    , config : Config
    , personalPath: Data.PersonalPath.PersonalPath
    }


init : Config -> Location -> ( AppModel, Cmd Msg )
init config location =
    let
        route =
            parseLocation location
    in
    ( { route = route
      , landing = LandingPage.State.initial
      , healthcheck = Healthcheck.initial config
      , login = Unauthenticated
      , path = Nothing
      , config = config
      , personalPath = Data.PersonalPath.initialState
      }
    , Cmd.batch [ Backend.loadLessons config.baseUrl, Backend.checkAuth config.baseUrl ]
    )


update : Msg -> AppModel -> ( AppModel, Cmd Msg )
update msg model =
    case Debug.log "message: " msg of
        ForLandingPage inner ->
            ( { model | landing = LandingPage.State.update inner model.landing }, Cmd.none )

        ForHealthCheck ->
            ( model, Cmd.none )

        ChangeLocation location ->
            ( { model | route = parseLocation location }, Cmd.none )

        ChangeRoute route ->
            ( { model | route = route }, newUrl (pageToUrl route) )

        ChangeAuth auth ->
            ( { model | login = auth }, Cmd.none )

        LoadPath path ->
            ( { model | path = path }, Cmd.none )

        SavePath ->
            ( model
            , Backend.savePath model.config.baseUrl model.landing.path
            )


pageView : AppModel -> Html Msg
pageView model =
  case model.route of
    LandingPage -> LandingPage.view model.landing
    Login -> LoginPage.view model.login
    PersonalPath -> View.PersonalPath.view model.path
    Healthcheck -> Healthcheck.view model.healthcheck
    NotFound -> Html.text "Not found :("


view : AppModel -> Html Msg
view model =
  Html.div [] [ Header.view model.login
              , pageView model
              ]


main : Program Config AppModel Msg
main =
    Navigation.programWithFlags
        ChangeLocation
        { init = init
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }
