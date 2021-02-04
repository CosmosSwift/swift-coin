import Foundation
import JSON
import ArgumentParser
import Tendermint
import Cosmos

struct AddGenesisAccountCommand: ParsableCommand {
    public static var defaultHome: String!
    public static var defaultClientHome: String!
    public static var codec: Codec!

    static var configuration = CommandConfiguration(
        commandName: "add-genesis-account",
        abstract: "Add a genesis account to genesis.json",
        discussion: """
                        Add a genesis account to genesis.json. The provided account must specify
                         the account address or key name and a list of initial coins. If a key name is given,
                         the address will be looked up in the local Keybase. The list of initial tokens must
                         contain valid denominations. Accounts may optionally be supplied with vesting parameters.
                    """)
    
    enum KeyRingBackend: String, CaseIterable, ExpressibleByArgument {
        case os, file, test
    }
    
    @Option(name: .long, help: "Node's home directory.")
    var home: String = Self.defaultHome
    
    @Option(name: .long, help: "Select keyring's backend (os|file|test).")
    var keyRingBackend: KeyRingBackend = .os
    
    @Option(name: .long, help: "Client's home directory.")
    var homeClient: String = Self.defaultClientHome

    @Option(name: .long, help: "Amount of coins for vesting accounts.")
    var vestingAmount: String = ""

    @Option(name: .long, help: "Schedule start time (unix epoch) for vesting accounts.")
    var vestingStartTime: Int = 0

    @Option(name: .long, help: "Schedule end time (unix epoch) for vesting accounts.")
    var vestingEndTime: Int = 0

    @Argument(help: ArgumentHelp("Address of the account.", valueName: "address"))
    var addressStr: String
    
    @Argument(help: ArgumentHelp("Coins.", valueName:"coins"))
    var coinsStr: String


    mutating func run() throws {
        // Get an address: Either through a valid address or through another mechanism (Keybase)
        guard let address = try? AccountAddress(bech32Encoded: addressStr) else {
            fatalError("Address provided is not valid.")
            // TODO: provide an alternate way of getting an address.
//            inBuf := bufio.NewReader(cmd.InOrStdin())
//            if err != nil {
//                // attempt to lookup address from Keybase if no address was provided
//                kb, err := keys.NewKeyring(
//                    sdk.KeyringServiceName(),
//                    viper.GetString(flags.FlagKeyringBackend),
//                    viper.GetString(flagClientHome),
//                    inBuf,
//                )
//                if err != nil {
//                    return err
//                }
//
//                info, err := kb.Get(args[0])
//                if err != nil {
//                    return fmt.Errorf("failed to get address from Keybase: %w", err)
//                }
//
//                addr = info.GetAddress()
//            }

        }
        // Get coins
        guard let coins = try? parseCoins(string: coinsStr) else {
            fatalError("Coins not properly defined.")
        }
        
        // Depending on type of account, base of vesting, instantiate account
        let account = BaseAccount(address: address, coins: coins)
        // TODO: implement vesting accounts
//        if !vestingAmt.IsZero() {
//            baseVestingAccount, err := authvesting.NewBaseVestingAccount(baseAccount, vestingAmt.Sort(), vestingEnd)
//            if err != nil {
//                return fmt.Errorf("failed to create base vesting account: %w", err)
//            }
//
//            switch {
//            case vestingStart != 0 && vestingEnd != 0:
//                genAccount = authvesting.NewContinuousVestingAccountRaw(baseVestingAccount, vestingStart)
//
//            case vestingEnd != 0:
//                genAccount = authvesting.NewDelayedVestingAccountRaw(baseVestingAccount)
//
//            default:
//                return errors.New("invalid vesting parameters; must supply start and end time or end time")
//            }
//        } else {
//            genAccount = baseAccount
//        }
//
//        if err := genAccount.Validate(); err != nil {
//            return fmt.Errorf("failed to validate new genesis account: %w", err)
//        }
        try account.validate()
        
        // Update genesis.json config with new account
        var configuration = ServerContext.configuration
        configuration.set(rootDirectory: home)
        let genesisFilePath = configuration.genesisFilePath

        guard FileManager.default.fileExists(atPath: genesisFilePath) else {
            fatalError("genesis.json file does not exist")
        }
        
        var genesisDocument: GenesisDocument<MetaSet<AppStateMetatype>>
        
        do {
            genesisDocument = try GenesisDocument(fileAtPath: genesisFilePath)
        } catch {
            throw CosmosError.wrap(
                error: error,
                description: "Failed to read genesis doc from file"
            )
        }
        
        //fatalError()
        
        // TODO: this should be implemented better...
        var authState = (genesisDocument.appState?.set.first(where: {type(of:$0).metatype == "auth"}) as! Cosmos.AuthGenesisState)
        genesisDocument.appState?.set.removeAll(where: {type(of:$0).metatype == "auth"})
        // TODO: do not append an account which has already been added.
        authState.accounts.append(account)
        
        genesisDocument.appState?.set.append(authState)
        
        
        do {
            try genesisDocument.exportGenesisFile(atPath: genesisFilePath)
        } catch {
            throw CosmosError.wrap(
                error: error,
                description: "Failed to export genesis file"
            )
        }
    }
    
}

func parseCoins(string: String) -> Coins? {
    let coinStrArray = string.split(separator: ",")
    
    var coins: [Coin] = []
    
    for coinStr in coinStrArray {
        // get the first char which is not number (or . when we handle DecCoin)
        // from there, it's the denom
        // the denom should be btw 3 and 16 char long, start with a lowercase letter, and the rest should be lowercase or number
        //
        let pattern = "[0-9]+"
        guard let amountRange = coinStr.range(of: pattern, options:.regularExpression) else {
            return nil
        }
        
        let amount = UInt(coinStr[amountRange]) ?? 0
        var denomination = coinStr
        denomination.removeSubrange(amountRange)
        coins.append(Coin(denomination: String(denomination), amount: amount))
    }
    return Coins(coins: coins)
}

/*
 package main

 import (
     "bufio"
     "errors"
     "fmt"

     "github.com/spf13/cobra"
     "github.com/spf13/viper"

     "github.com/tendermint/tendermint/libs/cli"

     "github.com/cosmos/cosmos-sdk/client/flags"
     "github.com/cosmos/cosmos-sdk/codec"
     "github.com/cosmos/cosmos-sdk/crypto/keys"
     "github.com/cosmos/cosmos-sdk/server"
     sdk "github.com/cosmos/cosmos-sdk/types"
     "github.com/cosmos/cosmos-sdk/x/auth"
     authexported "github.com/cosmos/cosmos-sdk/x/auth/exported"
     authvesting "github.com/cosmos/cosmos-sdk/x/auth/vesting"
     "github.com/cosmos/cosmos-sdk/x/genutil"
 )

 const (
     flagClientHome   = "home-client"
     flagVestingStart = "vesting-start-time"
     flagVestingEnd   = "vesting-end-time"
     flagVestingAmt   = "vesting-amount"
 )

 // AddGenesisAccountCmd returns add-genesis-account cobra Command.
 func AddGenesisAccountCmd(
     ctx *server.Context, cdc *codec.Codec, defaultNodeHome, defaultClientHome string,
 ) *cobra.Command {

     cmd := &cobra.Command{
         Use:   "add-genesis-account [address_or_key_name] [coin][,[coin]]",
         Short: "Add a genesis account to genesis.json",
         Long: `Add a genesis account to genesis.json. The provided account must specify
 the account address or key name and a list of initial coins. If a key name is given,
 the address will be looked up in the local Keybase. The list of initial tokens must
 contain valid denominations. Accounts may optionally be supplied with vesting parameters.
 `,
         Args: cobra.ExactArgs(2),
         RunE: func(cmd *cobra.Command, args []string) error {
             config := ctx.Config
             config.SetRoot(viper.GetString(cli.HomeFlag))

             addr, err := sdk.AccAddressFromBech32(args[0])
             inBuf := bufio.NewReader(cmd.InOrStdin())
             if err != nil {
                 // attempt to lookup address from Keybase if no address was provided
                 kb, err := keys.NewKeyring(
                     sdk.KeyringServiceName(),
                     viper.GetString(flags.FlagKeyringBackend),
                     viper.GetString(flagClientHome),
                     inBuf,
                 )
                 if err != nil {
                     return err
                 }

                 info, err := kb.Get(args[0])
                 if err != nil {
                     return fmt.Errorf("failed to get address from Keybase: %w", err)
                 }

                 addr = info.GetAddress()
             }

             coins, err := sdk.ParseCoins(args[1])
             if err != nil {
                 return fmt.Errorf("failed to parse coins: %w", err)
             }

             vestingStart := viper.GetInt64(flagVestingStart)
             vestingEnd := viper.GetInt64(flagVestingEnd)
             vestingAmt, err := sdk.ParseCoins(viper.GetString(flagVestingAmt))
             if err != nil {
                 return fmt.Errorf("failed to parse vesting amount: %w", err)
             }

             // create concrete account type based on input parameters
             var genAccount authexported.GenesisAccount

             baseAccount := auth.NewBaseAccount(addr, coins.Sort(), nil, 0, 0)
             if !vestingAmt.IsZero() {
                 baseVestingAccount, err := authvesting.NewBaseVestingAccount(baseAccount, vestingAmt.Sort(), vestingEnd)
                 if err != nil {
                     return fmt.Errorf("failed to create base vesting account: %w", err)
                 }

                 switch {
                 case vestingStart != 0 && vestingEnd != 0:
                     genAccount = authvesting.NewContinuousVestingAccountRaw(baseVestingAccount, vestingStart)

                 case vestingEnd != 0:
                     genAccount = authvesting.NewDelayedVestingAccountRaw(baseVestingAccount)

                 default:
                     return errors.New("invalid vesting parameters; must supply start and end time or end time")
                 }
             } else {
                 genAccount = baseAccount
             }

             if err := genAccount.Validate(); err != nil {
                 return fmt.Errorf("failed to validate new genesis account: %w", err)
             }

             genFile := config.GenesisFile()
             appState, genDoc, err := genutil.GenesisStateFromGenFile(cdc, genFile)
             if err != nil {
                 return fmt.Errorf("failed to unmarshal genesis state: %w", err)
             }

             authGenState := auth.GetGenesisStateFromAppState(cdc, appState)

             if authGenState.Accounts.Contains(addr) {
                 return fmt.Errorf("cannot add account at existing address %s", addr)
             }

             // Add the new account to the set of genesis accounts and sanitize the
             // accounts afterwards.
             authGenState.Accounts = append(authGenState.Accounts, genAccount)
             authGenState.Accounts = auth.SanitizeGenesisAccounts(authGenState.Accounts)

             authGenStateBz, err := cdc.MarshalJSON(authGenState)
             if err != nil {
                 return fmt.Errorf("failed to marshal auth genesis state: %w", err)
             }

             appState[auth.ModuleName] = authGenStateBz

             appStateJSON, err := cdc.MarshalJSON(appState)
             if err != nil {
                 return fmt.Errorf("failed to marshal application genesis state: %w", err)
             }

             genDoc.AppState = appStateJSON
             return genutil.ExportGenesisFile(genDoc, genFile)
         },
     }

     cmd.Flags().String(cli.HomeFlag, defaultNodeHome, "node's home directory")
     cmd.Flags().String(flags.FlagKeyringBackend, flags.DefaultKeyringBackend, "Select keyring's backend (os|file|test)")
     cmd.Flags().String(flagClientHome, defaultClientHome, "client's home directory")
     cmd.Flags().String(flagVestingAmt, "", "amount of coins for vesting accounts")
     cmd.Flags().Uint64(flagVestingStart, 0, "schedule start time (unix epoch) for vesting accounts")
     cmd.Flags().Uint64(flagVestingEnd, 0, "schedule end time (unix epoch) for vesting accounts")

     return cmd
 }
 */
