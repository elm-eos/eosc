module Eosc.Parser exposing (..)

import Char
import Eos
import Eosc.Command exposing (..)
import Parser exposing (..)


command : Parser Command
command =
    succeed identity
        |= oneOf
            [ getCommand ]


getCommand : Parser Command
getCommand =
    inContext "get" <|
        succeed GetCommand
            |. keyword "get"
            |. spaces
            |= oneOf
                [ inContext "info" <|
                    succeed GetInfo
                        |. keyword "info"
                , inContext "block" <|
                    succeed GetBlock
                        |. keyword "block"
                        |. spaces
                        |= blockRef
                        |. end
                , inContext "code" <|
                    succeed GetCode
                        |. keyword "code"
                        |. spaces
                        |= accountName
                        |. end
                , inContext "accounts" <|
                    succeed GetAccounts
                        |. keyword "accounts"
                        |. spaces
                        |= publicKey
                        |. end
                , inContext "account" <|
                    succeed GetAccount
                        |. keyword "account"
                        |. spaces
                        |= accountName
                        |. end
                , inContext "servants" <|
                    succeed GetServants
                        |. keyword "servants"
                        |. spaces
                        |= accountName
                        |. end
                , inContext "table" <|
                    succeed GetTable
                        |. keyword "servants"
                        |. spaces
                        |= accountName
                        |. spaces
                        |= accountName
                        |. spaces
                        |= tableName
                        |. end
                , inContext "transactions" <|
                    succeed GetTransactions
                        |. keyword "transactions"
                        |. spaces
                        |= accountName
                        |. spaces
                        |= oneOf
                            [ map Just int
                            , succeed Nothing
                            ]
                        |. spaces
                        |= oneOf
                            [ map Just int
                            , succeed Nothing
                            ]
                        |. end
                , inContext "transaction" <|
                    succeed GetTransaction
                        |. keyword "transaction"
                        |. spaces
                        |= transactionId
                        |. end
                ]


spaces : Parser String
spaces =
    keep zeroOrMore (\c -> c == ' ')


accountName : Parser Eos.AccountName
accountName =
    inContext "account name" <|
        map Eos.accountName <|
            keep (AtLeast 1)
                (\c ->
                    Char.isUpper c
                        || Char.isLower c
                        || isCharBetween '0' '5' c
                )


blockRef : Parser Eos.BlockRef
blockRef =
    oneOf
        [ blockNum
        , blockId
        ]


blockNum : Parser Eos.BlockRef
blockNum =
    inContext "block number" <|
        map Eos.blockNum int


blockId : Parser Eos.BlockRef
blockId =
    inContext "block id" <|
        map Eos.blockId <|
            keep (Exactly 64) isAlphaNumeric


publicKey : Parser Eos.PublicKey
publicKey =
    inContext "public key" <|
        succeed identity
            |. keyword "EOS"
            |= map
                (\s -> Eos.publicKey <| "EOS" ++ s)
                (keep (Exactly 50) isAlphaNumeric)


tableName : Parser Eos.TableName
tableName =
    inContext "table name" <|
        map Eos.tableName <|
            keep oneOrMore isAlphaNumeric


transactionId : Parser Eos.TransactionId
transactionId =
    inContext "transaction id" <|
        map Eos.transactionId <|
            keep oneOrMore isAlphaNumeric


isAlphaNumeric : Char -> Bool
isAlphaNumeric c =
    Char.isUpper c
        || Char.isLower c
        || Char.isDigit c


isCharBetween : Char -> Char -> Char -> Bool
isCharBetween low high char =
    let
        code =
            Char.toCode char
    in
    (code >= Char.toCode low) && (code <= Char.toCode high)
