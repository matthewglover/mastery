module Main exposing (..)

import Backend
import Header
import Healthcheck.Healthcheck as Healthcheck
import Html
import LandingPage.LandingPage as LandingPage
import LandingPage.State exposing (Model)
import LoginPage.LoginPage as LoginPage exposing (..)
import Messages exposing (Auth(..), Msg(..))
import MyPath
import Navigation exposing (..)
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
    , path : Maybe MyPath.Path
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
      }
    , Cmd.batch [ Backend.loadLessons config.baseUrl, Backend.checkAuth config.baseUrl, Backend.loadPath config.baseUrl ]
    )


update : Msg -> AppModel -> ( AppModel, Cmd Msg )
update msg model =
    case msg of
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

        LoadPath lessons ->
            ( { model | path = MyPath.initial lessons }, Cmd.none )


page : AppModel -> Html.Html Msg
page model =
    let
        framed =
            frame model.login
    in
    case model.route of
        LandingPage ->
            framed <| LandingPage.view model.landing

        Healthcheck ->
            framed <| Healthcheck.view model.healthcheck

        Login ->
            framed <| LoginPage.view model.login

        NotFound ->
            framed <| Html.text "Not found :("

        MyPath ->
            framed <| MyPath.view model.path


frame : Auth -> Html.Html Msg -> Html.Html Msg
frame auth html =
    Html.div [] [ Header.view auth, html ]


main : Program Config AppModel Msg
main =
    Navigation.programWithFlags
        ChangeLocation
        { init = init
        , view = page
        , update = update
        , subscriptions = \model -> Sub.none
        }
