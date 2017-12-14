port module Main exposing (..)

import Eosc
import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode
import Task


type Msg
    = Msg (Result Eosc.Error Value)


type alias Model =
    String


main : Program Value Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : Value -> ( Model, Cmd Msg )
init value =
    let
        query =
            value
                |> Decode.decodeValue Decode.string
                |> Result.withDefault ""
    in
    query ! [ Task.attempt Msg <| Eosc.run query ]


update : Msg -> Model -> ( Model, Cmd Msg )
update (Msg result) model =
    case result of
        Ok value ->
            model ! [ stdout <| Encode.encode 4 value ]

        Err err ->
            model ! [ stderr <| Basics.toString err ]


port stdout : String -> Cmd msg


port stderr : String -> Cmd msg
