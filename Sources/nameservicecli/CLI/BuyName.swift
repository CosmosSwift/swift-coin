import Foundation
import ArgumentParser
import Cosmos
import Auth
import NameService
import Tendermint

struct BuyNameMessage: Message {
    
    static var metaType: MetaType = Self.metaType(
        key: "cosmos-sdk/BuyNameMsg" // TODO: is this the right string?
    )
    
    let name: String
    let bid: [Coin]
    let buyer: AccountAddress
}

extension BuyNameMessage {
    // Route Implements Msg.
    var route: String {
        NameServiceKeys.routerKey
    }

    // Type Implements Msg.
    var type: String {
        "buy_name"
    }

    // ValidateBasic Implements Msg.
    func validateBasic() throws { // TODO:
        guard !buyer.isEmpty else {
            throw Cosmos.Error.invalidAddress(address: "missing buyer address")
        }
        
        guard bid.isValid else {
            throw Cosmos.Error.invalidCoins(reason: "\(bid)")
        }
        
        guard bid.isAllPositive else {
            throw Cosmos.Error.invalidCoins(reason: "\(bid)")
        }
    }

    // GetSignBytes Implements Msg.
    var signedData: Data {
        mustSortJSON(data: Codec.bankCodec.mustMarshalJSON(value: self))
    }

    // GetSigners Implements Msg.
    var signers: [AccountAddress] {
        [buyer]
    }
}

public struct BuyName: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "buy-name",
        abstract: "Buys a new name."
    )
    @OptionGroup
    private var clientOptions: ClientOptions

    @OptionGroup var txFlags: Flags.TransactionFlags
      
    @Argument(help: "Domain name to buy.")
    var name: String
    
    @Argument(help: "Price.")
    var price: [Coin]
    
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
        
        let txBuilder = try TransactionBuilder<StandardTransaction>(
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
        
        //txBuilder.keybase = keybase
        
        let buyerKey: KeyInfo
        switch self.txFlags.from {
        case let .address(address):
            buyerKey = try keybase.getByAddress(address: address)
        case let .name(name):
            buyerKey = try keybase.get(name: name)
        }

        print(buyerKey)
        

        
        // TODO: incorporate memo, chainId, accountNumber, sequence
        let message = try JSONEncoder().encode(BuyNameMessage(name: self.name, bid: self.price, buyer: buyerKey.address))
        
        let (sig, _) = try keybase.sign(name: buyerKey.name, passphrase: "", message: message)
        
        print(sig.hexEncodedString())
        
        
        // TODO: sign transaction using the key
        
        // TODO: send a broadcast transaction
        
        // TODO: print response ?
        
        
//        RunE: func(cmd *cobra.Command, args []string) error {
//            argsName := string(args[0])
//
//            cliCtx := context.NewCLIContext().WithCodec(cdc)
//            inBuf := bufio.NewReader(cmd.InOrStdin())
//            txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))
//
//            coins, err := sdk.ParseCoins(args[1])
//            if err != nil {
//                return err
//            }
//
//            msg := types.NewMsgBuyName(argsName, coins, cliCtx.GetFromAddress())
//            err = msg.ValidateBasic()
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

 func GetCmdBuyName(cdc *codec.Codec) *cobra.Command {
     return &cobra.Command{
         Use:   "buy-name [name] [price]",
         Short: "Buys a new name",
         Args:  cobra.ExactArgs(2),
         RunE: func(cmd *cobra.Command, args []string) error {
             argsName := string(args[0])

             cliCtx := context.NewCLIContext().WithCodec(cdc)
             inBuf := bufio.NewReader(cmd.InOrStdin())
             txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))

             coins, err := sdk.ParseCoins(args[1])
             if err != nil {
                 return err
             }

             msg := types.NewMsgBuyName(argsName, coins, cliCtx.GetFromAddress())
             err = msg.ValidateBasic()
             if err != nil {
                 return err
             }
             return utils.GenerateOrBroadcastMsgs(cliCtx, txBldr, []sdk.Msg{msg})
         },
     }
 }

 */
