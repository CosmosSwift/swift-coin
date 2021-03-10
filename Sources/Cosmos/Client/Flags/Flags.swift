//
//  File.swift
//  
//
//  Created by Jaap Wijnen on 10/02/2021.
//

import Foundation
import ArgumentParser



#warning("This should probably be moved elsewhere")
extension AccountAddress: ExpressibleByArgument {
    public init?(argument: String) {
        try? self.init(bech32Encoded: argument)
    }
}

extension Coin: ExpressibleByArgument {
    public init?(argument: String) {
        
        try? self.init(string: argument)
    }
}

extension DecimalCoin: ExpressibleByArgument {
    public init?(argument: String) {
        
        try? self.init(string: argument)
    }
}

public enum Flags {
    #warning("NodeURL should probably be moved?")
    public struct NodeURL: ExpressibleByArgument {
        public enum URLScheme: String {
            case tcp
            case http
            case https
        }
        
        public let scheme: URLScheme
        public let host: String
        public let port: Int
        
        public init?(argument: String) {
            let parts = argument.split(separator: ":")
            switch parts.count {
            case 3:
                guard let scheme = URLScheme(rawValue: String(parts[0]))  else {
                    return nil
                }
                self.scheme = scheme
                self.host = String(parts[1].dropFirst(2))
                guard let port = Int(parts[2]) else {
                    return nil
                }
                self.port = port
            case 2:
                self.scheme = .tcp
                self.host = String(parts[0])
                guard let port = Int(parts[1]) else {
                    return nil
                }
                self.port = port
            default:
                return nil
            }
        }
    }
    
    public struct QueryFlags: ParsableArguments {
        #warning("where should this live? here? Or somewhere more general?")
        public enum OutputFormat: String, ExpressibleByArgument {
            case text
            case json
        }
        
        #warning("the <host>:<port> format seems like it could leverage some type safety")
        @Option(help: "<host>:<port> to Tendermint RPC interface for this chain")
        public var node: NodeURL = NodeURL(argument: "tcp://localhost:26657")!
        
        @Option(help: "Use a specific height to query state at (this can error if the node is pruning state)")
        public var height: Int = 0
        
        #warning("This actually comes from the tendermint import")
        @Option(name: .shortAndLong, help: "Output format (text|json)")
        public var output: OutputFormat = .text
        
        #warning("this comes from the root command but is marked required (in go) for this implementation specifically")
        @Option(help: "The network chain ID")
        public var chainId: String
        
        public init() { }
        
        #warning("Does this need porting?")
        // cmd.SetErr(cmd.ErrOrStderr())
        // cmd.SetOut(cmd.OutOrStdout())
    }
    
    public struct TransactionFlags: ParsableArguments {
        public enum BroadcastMode: String, ExpressibleByArgument {
            case sync
            case async
            case block
        }
        
        public enum SignMode: String, ExpressibleByArgument {
            case direct
            case amino_json // TODO: amino should be removed
        }
        
        public enum GasLimitPerTransaction: CustomStringConvertible, ExpressibleByArgument {
            public init?(argument: String) {
                if argument == "auto" {
                    self = .auto
                    return
                }
                if let limit = UInt64(argument) {
                    self = .limit(perTransaction: limit)
                    return
                }
                return nil
            }
            
            case auto
            case limit(perTransaction: UInt64 = 20000)
            
            public var description: String {
                switch self {
                    case .auto:
                     return "auto"
                    case let .limit(perTransaction: value):
                    return String(value)
                }
            }
        }
        
        public enum AddressOrName: ExpressibleByArgument {
            public init?(argument: String) {
                if let address = AccountAddress(argument: argument) {
                    self = .address(address)
                } else {
                    self = .name(argument)
                }
                return
            }
            
            case name(String)
            case address(AccountAddress)
        }
        
        #warning("the <host>:<port> format seems like it could leverage some type safety")
        @Option(help: "<host>:<port> to Tendermint RPC interface for this chain")
        public var node: NodeURL = NodeURL(argument: "tcp://localhost:26657")!
        
        @Option(help: "Use a specific height to query state at (this can error if the node is pruning state)")
        public var height: Int = 0
        
        #warning("this comes from the root command but is marked required (in go) for this implementation specifically")
        @Option(help: "The network chain ID")
        public var chainId: String // TODO: this is required
                
        @Option(help: "The client Keyring directory; if omitted, the default 'home' directory will be used")
        public var keyringDir: String? // TODO: this should have a default
        
        @Option(help: "Name or address of private key with which to sign")
        public var from: AddressOrName // TODO: this can also be a name (String)
        
        @Option(name: .customShort("a"), help:"The account number of the signing account (offline mode only)")
        public var accountNumber: UInt64? // TODO: this should have a default
        
        @Option(name: .customShort("s"), help: "The sequence number of the signing account (offline mode only)")
        public var sequence: UInt64? // TODO: this should have a default
        
        @Option(help: "Memo to send along with transaction")
        public var memo: String? // TODO: this should have a default
        
        @Option(help: "Fees to pay along with transaction; eg: 10uatom")
        public var fees: Coin? // TODO: this should have a default
        
        @Option(help: "Gas prices in decimal format to determine the transaction fee (e.g. 0.1uatom)")
        public var gasPrice: DecimalCoin?
        
        @Flag(help: "Use a connected Ledger device")
        public var useLedger: Bool = false
        
        @Option(help: "adjustment factor to be multiplied against the estimate returned by the tx simulation; if the gas limit is set manually this flag is ignored ")
        public var gasAdjustment: Float64 = 1.0
        
        @Option(name: .customShort("b"), help: "Transaction broadcasting mode (sync|async|block)")
        public var broadcastMode: BroadcastMode = .sync // TODO: what should be teh default?
        
        @Flag(help: "ignore the --gas flag and perform a simulation of a transaction, but don't broadcast it")
        public var dryRun: Bool = false
        
        @Flag(help: "Build an unsigned transaction and write it to STDOUT (when enabled, the local Keybase is not accessible)")
        public var generateOnly: Bool = false
        
        @Flag(help: "Offline mode (does not allow any online functionality")
        public var offline: Bool = false
        
        @Flag(name: .customShort("y"), help: "Skip tx broadcasting prompt confirmation")
        public var skipConfirmation: Bool = false

        @Option(help: "Select keyring's backend (os|file|kwallet|pass|test)")
        public var keyringBackend: KeyringBackend = .os
        
        @Option(help: "Choose sign mode (direct|amino-json), this is an advanced feature")
        public var signMode: SignMode = .direct // TODO: what should be the default?
        
        @Option(help: "Set a block timeout height to prevent the tx from being committed past a certain height")
        public var timeOutHeight: UInt64? // TODO: what should be the default here?
        // --gas can accept integers and "auto"
        // auto means that the system will run in simulation mode an compute a suitable value
        @Option(help: "gas limit to set per-transaction; set to \(GasLimitPerTransaction.auto) to calculate sufficient gas automatically (default \(GasLimitPerTransaction.limit)")
        public var gas: GasLimitPerTransaction = .limit() // TODO: what should be the default here?
        
        
        public init() { }
        
        #warning("Does this need porting?")
        // cmd.SetErr(cmd.ErrOrStderr())
        // cmd.SetOut(cmd.OutOrStdout())

    }
}



/*
 
 package flags

 import (
     "fmt"
     "strconv"

     "github.com/spf13/cobra"
     tmcli "github.com/tendermint/tendermint/libs/cli"

     "github.com/cosmos/cosmos-sdk/crypto/keyring"
 )

 const (
     // DefaultGasAdjustment is applied to gas estimates to avoid tx execution
     // failures due to state changes that might occur between the tx simulation
     // and the actual run.
     DefaultGasAdjustment = 1.0
     DefaultGasLimit      = 200000
     GasFlagAuto          = "auto"

     // DefaultKeyringBackend
     DefaultKeyringBackend = keyring.BackendOS

     // BroadcastBlock defines a tx broadcasting mode where the client waits for
     // the tx to be committed in a block.
     BroadcastBlock = "block"
     // BroadcastSync defines a tx broadcasting mode where the client waits for
     // a CheckTx execution response only.
     BroadcastSync = "sync"
     // BroadcastAsync defines a tx broadcasting mode where the client returns
     // immediately.
     BroadcastAsync = "async"

     // SignModeDirect is the value of the --sign-mode flag for SIGN_MODE_DIRECT
     SignModeDirect = "direct"
     // SignModeLegacyAminoJSON is the value of the --sign-mode flag for SIGN_MODE_LEGACY_AMINO_JSON
     SignModeLegacyAminoJSON = "amino-json"
 )

 // List of CLI flags
 const (
     FlagHome             = tmcli.HomeFlag
     FlagKeyringDir       = "keyring-dir"
     FlagUseLedger        = "ledger"
     FlagChainID          = "chain-id"
     FlagNode             = "node"
     FlagHeight           = "height"
     FlagGasAdjustment    = "gas-adjustment"
     FlagFrom             = "from"
     FlagName             = "name"
     FlagAccountNumber    = "account-number"
     FlagSequence         = "sequence"
     FlagMemo             = "memo"
     FlagFees             = "fees"
     FlagGas              = "gas"
     FlagGasPrices        = "gas-prices"
     FlagBroadcastMode    = "broadcast-mode"
     FlagDryRun           = "dry-run"
     FlagGenerateOnly     = "generate-only"
     FlagOffline          = "offline"
     FlagOutputDocument   = "output-document" // inspired by wget -O
     FlagSkipConfirmation = "yes"
     FlagProve            = "prove"
     FlagKeyringBackend   = "keyring-backend"
     FlagPage             = "page"
     FlagLimit            = "limit"
     FlagSignMode         = "sign-mode"
     FlagPageKey          = "page-key"
     FlagOffset           = "offset"
     FlagCountTotal       = "count-total"
     FlagTimeoutHeight    = "timeout-height"
     FlagKeyAlgorithm     = "algo"

     // Tendermint logging flags
     FlagLogLevel  = "log_level"
     FlagLogFormat = "log_format"
 )

 // LineBreak can be included in a command list to provide a blank line
 // to help with readability
 var LineBreak = &cobra.Command{Run: func(*cobra.Command, []string) {}}


 // AddTxFlagsToCmd adds common flags to a module tx command.
 func AddTxFlagsToCmd(cmd *cobra.Command) {
     cmd.Flags().String(FlagKeyringDir, "", "The client Keyring directory; if omitted, the default 'home' directory will be used")
     cmd.Flags().String(FlagFrom, "", "Name or address of private key with which to sign")
     cmd.Flags().Uint64P(FlagAccountNumber, "a", 0, "The account number of the signing account (offline mode only)")
     cmd.Flags().Uint64P(FlagSequence, "s", 0, "The sequence number of the signing account (offline mode only)")
     cmd.Flags().String(FlagMemo, "", "Memo to send along with transaction")
     cmd.Flags().String(FlagFees, "", "Fees to pay along with transaction; eg: 10uatom")
     cmd.Flags().String(FlagGasPrices, "", "Gas prices in decimal format to determine the transaction fee (e.g. 0.1uatom)")
     cmd.Flags().String(FlagNode, "tcp://localhost:26657", "<host>:<port> to tendermint rpc interface for this chain")
     cmd.Flags().Bool(FlagUseLedger, false, "Use a connected Ledger device")
     cmd.Flags().Float64(FlagGasAdjustment, DefaultGasAdjustment, "adjustment factor to be multiplied against the estimate returned by the tx simulation; if the gas limit is set manually this flag is ignored ")
     cmd.Flags().StringP(FlagBroadcastMode, "b", BroadcastSync, "Transaction broadcasting mode (sync|async|block)")
     cmd.Flags().Bool(FlagDryRun, false, "ignore the --gas flag and perform a simulation of a transaction, but don't broadcast it")
     cmd.Flags().Bool(FlagGenerateOnly, false, "Build an unsigned transaction and write it to STDOUT (when enabled, the local Keybase is not accessible)")
     cmd.Flags().Bool(FlagOffline, false, "Offline mode (does not allow any online functionality")
     cmd.Flags().BoolP(FlagSkipConfirmation, "y", false, "Skip tx broadcasting prompt confirmation")
     cmd.Flags().String(FlagKeyringBackend, DefaultKeyringBackend, "Select keyring's backend (os|file|kwallet|pass|test)")
     cmd.Flags().String(FlagSignMode, "", "Choose sign mode (direct|amino-json), this is an advanced feature")
     cmd.Flags().Uint64(FlagTimeoutHeight, 0, "Set a block timeout height to prevent the tx from being committed past a certain height")

     // --gas can accept integers and "auto"
     cmd.Flags().String(FlagGas, "", fmt.Sprintf("gas limit to set per-transaction; set to %q to calculate sufficient gas automatically (default %d)", GasFlagAuto, DefaultGasLimit))

     cmd.MarkFlagRequired(FlagChainID)

     cmd.SetErr(cmd.ErrOrStderr())
     cmd.SetOut(cmd.OutOrStdout())
 }

 // AddPaginationFlagsToCmd adds common pagination flags to cmd
 func AddPaginationFlagsToCmd(cmd *cobra.Command, query string) {
     cmd.Flags().Uint64(FlagPage, 1, fmt.Sprintf("pagination page of %s to query for. This sets offset to a multiple of limit", query))
     cmd.Flags().String(FlagPageKey, "", fmt.Sprintf("pagination page-key of %s to query for", query))
     cmd.Flags().Uint64(FlagOffset, 0, fmt.Sprintf("pagination offset of %s to query for", query))
     cmd.Flags().Uint64(FlagLimit, 100, fmt.Sprintf("pagination limit of %s to query for", query))
     cmd.Flags().Bool(FlagCountTotal, false, fmt.Sprintf("count total number of records in %s to query for", query))
 }

 // GasSetting encapsulates the possible values passed through the --gas flag.
 type GasSetting struct {
     Simulate bool
     Gas      uint64
 }

 func (v *GasSetting) String() string {
     if v.Simulate {
         return GasFlagAuto
     }

     return strconv.FormatUint(v.Gas, 10)
 }

 // ParseGasSetting parses a string gas value. The value may either be 'auto',
 // which indicates a transaction should be executed in simulate mode to
 // automatically find a sufficient gas value, or a string integer. It returns an
 // error if a string integer is provided which cannot be parsed.
 func ParseGasSetting(gasStr string) (GasSetting, error) {
     switch gasStr {
     case "":
         return GasSetting{false, DefaultGasLimit}, nil

     case GasFlagAuto:
         return GasSetting{true, 0}, nil

     default:
         gas, err := strconv.ParseUint(gasStr, 10, 64)
         if err != nil {
             return GasSetting{}, fmt.Errorf("gas must be either integer or %s", GasFlagAuto)
         }

         return GasSetting{false, gas}, nil
     }
 }

 */
