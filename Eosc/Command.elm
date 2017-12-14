module Eosc.Command exposing (..)

import Eos


type Command
    = CreateCommand CreateCommand
    | GetCommand GetCommand
    | SetCommand SetCommand
    | TransferCommand TransferCommand
    | NetCommand NetCommand
    | PushCommand PushCommand


type VersionCommand
    = ClientVersion


type CreateCommand
    = CreateKey
    | CreateAccount
    | CreateProducer


type GetCommand
    = GetInfo
    | GetBlock Eos.BlockRef
    | GetAccount Eos.AccountName
    | GetCode Eos.AccountName
    | GetTable Eos.AccountName Eos.AccountName Eos.TableName
    | GetAccounts Eos.PublicKey
    | GetServants Eos.AccountName
    | GetTransaction Eos.TransactionId
    | GetTransactions Eos.AccountName (Maybe Int) (Maybe Int)


type SetCommand
    = SetContract
    | SetProducer
    | SetProxy
    | SetAccount
    | SetAction


type TransferCommand
    = Transfer


type NetCommand
    = NetConnect
    | NetDisconnect
    | NetStatus
    | NetPeers


type WalletCommand
    = WalletCreate
    | WalletOpen
    | WalletLock
    | WalletLockAll
    | WalletUnlock
    | WalletImport
    | WalletList
    | WalletKeys


type PushCommand
    = PushMessage
    | PushTransaction
    | PushTransactions


type alias GlobalOptions =
    { help : Bool
    , host : String
    , port_ : Int
    , walletHost : String
    , walletPort : String
    }
