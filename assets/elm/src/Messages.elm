module Messages exposing (..)

import LandingPage.State exposing (Msg)
import Navigation exposing (Location)
import Data.PersonalPath exposing (Path)
import Routing exposing (Route(..))


type Auth
    = LoggedIn String
    | Unauthenticated


type Msg
    = ForLandingPage LandingPage.State.Msg
    | ForHealthCheck
    | ChangeLocation Location
    | ChangeRoute Route
    | ChangeAuth Auth
    | LoadPath (Maybe Path)
    | SavePath
