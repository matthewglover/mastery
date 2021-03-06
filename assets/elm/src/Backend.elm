module Backend exposing (..)

import Debug
import Http
import Json.Decode as Decode
import LandingPage.State
import Lesson exposing (..)
import Messages exposing (Auth(..), Msg(..))
import PersonalPath exposing (Path)


savePath : String -> Path -> Cmd Msg
savePath url path =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = url ++ "/api/path"
                , body = Http.jsonBody (PersonalPath.encode path)
                , expect = Http.expectJson PersonalPath.decode
                , timeout = Nothing
                , withCredentials = True
                }

        mapping result =
            result
                |> Result.toMaybe
                |> LoadPath
    in
    Http.send mapping request


loadLessons : String -> Cmd Msg
loadLessons url =
    let
        mapping result =
            result
                |> Result.withDefault []
                |> (\lessons -> ForLandingPage (LandingPage.State.LoadModules lessons))

        request =
            Http.get (url ++ "/api/lessons") Lesson.decodeList
    in
    Http.send mapping request


loadPath : String -> Cmd Msg
loadPath url =
    let
        mapping result =
            result
                |> Result.toMaybe
                |> LoadPath

        request =
            Http.get (url ++ "/api/path") PersonalPath.decode
    in
    Http.send mapping request


checkAuth : String -> Cmd Msg
checkAuth url =
    let
        mapping result =
            result
                |> Result.map ChangeAuth
                |> Result.withDefault (ChangeAuth Unauthenticated)
    in
    Http.send mapping <| buildRequest url


buildRequest : String -> Http.Request Auth
buildRequest url =
    Http.request
        { method = "GET"
        , headers = []
        , url = url ++ "/api/authorization/check"
        , body = Http.emptyBody
        , expect = Http.expectJson decode_auth
        , timeout = Nothing
        , withCredentials = True
        }


decode_auth : Decode.Decoder Auth
decode_auth =
    Decode.map2 stateToAuth
        (Decode.field "state" Decode.string)
        (Decode.maybe (Decode.field "user" decodeUser))


decodeUser : Decode.Decoder String
decodeUser =
    Decode.field "name" Decode.string


stateToAuth : String -> Maybe String -> Auth
stateToAuth state maybe_user =
    case Debug.log "login: " ( state, maybe_user ) of
        ( "authenticated", Just user ) ->
            LoggedIn user

        _ ->
            Unauthenticated
