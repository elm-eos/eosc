module Eosc exposing (..)

import Eos
import Eos.Encode as Encode
import Eos.Http.AccountHistory
import Eos.Http.Chain
import Eosc.Command exposing (..)
import Eosc.Parser
import Http
import Json.Decode as Decode exposing (Value)
import Parser
import Task exposing (Task)


type Error
    = Error String
    | ParserError Parser.Error
    | HttpError Http.Error
    | UnimplementedError


run : String -> Task Error Value
run input =
    case parseCommand input of
        Ok command ->
            runCommand command

        Err err ->
            Task.fail <| ParserError err


parseCommand : String -> Result Parser.Error Command
parseCommand =
    Parser.run Eosc.Parser.command


runCommand : Command -> Task Error Value
runCommand command =
    let
        baseUrl =
            Eos.baseUrl "https://t1readonly.eos.io"

        send encode request =
            request
                |> Http.toTask
                |> Task.map encode
                |> Task.mapError HttpError
    in
    case command of
        GetCommand getCommand ->
            case getCommand of
                GetInfo ->
                    send Encode.info <|
                        Eos.Http.Chain.getInfo baseUrl

                GetBlock blockRef ->
                    send Encode.block <|
                        Eos.Http.Chain.getBlock baseUrl blockRef

                GetAccount accountName ->
                    send Encode.account <|
                        Eos.Http.Chain.getAccount baseUrl accountName

                GetCode accountName ->
                    send Encode.code <|
                        Eos.Http.Chain.getCode baseUrl accountName

                GetServants accountName ->
                    send Encode.controlledAccounts <|
                        Eos.Http.AccountHistory.getControlledAccounts baseUrl accountName

                GetAccounts publicKey ->
                    send Encode.keyAccounts <|
                        Eos.Http.AccountHistory.getKeyAccounts baseUrl publicKey

                GetTable scope contract table ->
                    send (Encode.tableRows identity) <|
                        Eos.Http.Chain.getTableRows baseUrl
                            { scope = scope
                            , code = contract
                            , table = table
                            , rowDecoder = Decode.value
                            }

                GetTransaction transactionId ->
                    send (Encode.pushedTransaction identity) <|
                        Eos.Http.AccountHistory.getTransaction baseUrl
                            transactionId
                            Decode.value

                GetTransactions accountName skipSeq numSeq ->
                    send (Encode.pushedTransactions identity) <|
                        Eos.Http.AccountHistory.getTransactions baseUrl
                            { accountName = accountName
                            , skipSeq = skipSeq
                            , numSeq = numSeq
                            , msgDataDecoder = Decode.value
                            }

        _ ->
            Task.fail UnimplementedError
