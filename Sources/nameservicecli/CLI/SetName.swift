import Foundation
import ArgumentParser
import Cosmos
import Auth
import NameService
import Tendermint
import AsyncHTTPClient


public struct SetName: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "set-name",
        abstract: "Set a new name."
    )

    @OptionGroup
    private var clientOptions: ClientOptions
    
    @OptionGroup var txFlags: Flags.TransactionFlags
    
    @Argument(help: "Domain name to set.")
    var name: String
    
    @Argument(help: "New value.")
    var value: String


    public init() {}
    
    public mutating func run() throws {
        var fs: FeeStructure?
        if let fee = txFlags.fees {
            fs = .fees([fee])
        } else if let gasPrice = txFlags.gasPrice {
            fs = .gasPrice([gasPrice])
        }
        guard let feeStructure = fs else {
            throw Cosmos.Error.generic(reason: "missing fee or gasPrice")
        }
        
        var txBuilder = try TransactionBuilder<StandardTransaction>(
            transactionEncoder: Auth.defaultTransactionEncoder(codec: Codec()),
            accountNumber: txFlags.accountNumber ?? 0,
            sequence: txFlags.sequence ?? 0,
            gas: txFlags.gas,
            gasAdjustment: txFlags.gasAdjustment,
            simulateAndExecute: !txFlags.generateOnly,
            chainID: txFlags.chainId,
            memo: txFlags.memo ?? "",
            feeStructure: feeStructure
        )
        
        
        let keybase = try makeKeyring(
            appName: Configuration.keyringServiceName,
            backend: txFlags.keyringBackend,
            rootDirectory: clientOptions.home
        )
        
        txBuilder.keybase = keybase
        
        let setterKey: KeyInfo
        switch self.txFlags.from {
        case let .address(address):
            setterKey = try keybase.getByAddress(address: address)
        case let .name(name):
            setterKey = try keybase.get(name: name)
        }
        
        //print(buyerKey)
        
        
        
        // TODO: incorporate memo, chainId, accountNumber, sequence
        let message = SetNameMessage(name: self.name, value: self.value, owner: setterKey.address)
        
//        let (sig, _) = try keybase.sign(name: buyerKey.name, passphrase: "", message: message)
//
//        print(sig.hexEncodedString())
        
        
        // TODO: sign transaction using the key
        let transaction = try txBuilder.buildAndSign(name: setterKey.name, passPhrase: "", messages: [message])
        // TODO: send a broadcast transaction
        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        defer {
            try? httpClient.syncShutdown()
        }
        
        let client = RESTClient(url: txFlags.node.description, httpClient: httpClient)
        
        let params = RESTBroadcastTransactionParameters(transaction: transaction)
        
        let response: RESTResponse<Cosmos.TransactionResponse> = try client.broadcastTransaction(params: params, mode: txFlags.broadcastMode).wait()
        
        let data = try JSONEncoder().encode(response)
        
        if let result = String(data:data, encoding: .utf8) {
            print(result)
        } else {
            print("Response is corrupt and not able to generate a JSON string.")
        }
//        RunE: func(cmd *cobra.Command, args []string) error {
//            argsValue := args[0]
//            argsName := args[1]
//
//            cliCtx := context.NewCLIContext().WithCodec(cdc)
//            inBuf := bufio.NewReader(cmd.InOrStdin())
//            txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))
//            msg := types.NewMsgSetName(cliCtx.GetFromAddress(), argsValue, argsName)
//            err := msg.ValidateBasic()
//            if err != nil {
//                return err
//            }
//            return utils.GenerateOrBroadcastMsgs(cliCtx, txBldr, []sdk.Msg{msg})
//        },
    }
}


/*
 package cli

 import (
     "bufio"

     "github.com/spf13/cobra"

     "github.com/cosmos/cosmos-sdk/client/context"
     "github.com/cosmos/cosmos-sdk/codec"
     sdk "github.com/cosmos/cosmos-sdk/types"
     "github.com/cosmos/cosmos-sdk/x/auth"
     "github.com/cosmos/cosmos-sdk/x/auth/client/utils"
     "github.com/cosmos/sdk-tutorials/nameservice/nameservice/x/nameservice/types"
 )

 func GetCmdSetWhois(cdc *codec.Codec) *cobra.Command {
     return &cobra.Command{
         Use:   "set-name [value] [name]",
         Short: "Set a new name",
         Args:  cobra.ExactArgs(2),
         RunE: func(cmd *cobra.Command, args []string) error {
             argsValue := args[0]
             argsName := args[1]

             cliCtx := context.NewCLIContext().WithCodec(cdc)
             inBuf := bufio.NewReader(cmd.InOrStdin())
             txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))
             msg := types.NewMsgSetName(cliCtx.GetFromAddress(), argsValue, argsName)
             err := msg.ValidateBasic()
             if err != nil {
                 return err
             }
             return utils.GenerateOrBroadcastMsgs(cliCtx, txBldr, []sdk.Msg{msg})
         },
     }
 }
 */
