
import Foundation
import ABCIMessages

// InitChainer initializes application state at genesis
public typealias InitChainer = (_ request: Request, _ initChainRequest: RequestInitChain) -> ResponseInitChain

// BeginBlocker runs code before the transactions in a block
//
// Note: applications which set create_empty_blocks=false will not have regular block timing and should use
// e.g. BFT timestamps rather than block height for any periodic BeginBlock logic
public typealias BeginBlocker = (_ request: Request, _ beginBlockRequest: RequestBeginBlock) -> ResponseBeginBlock

// EndBlocker runs code after the transactions in a block and return updates to the validator set
//
// Note: applications which set create_empty_blocks=false will not have regular block timing and should use
// e.g. BFT timestamps rather than block height for any periodic EndBlock logic
public typealias EndBlocker = (_ request: Request, _ endBlockRequest: RequestEndBlock) -> ResponseEndBlock

// PeerFilter responds to p2p filtering queries from Tendermint
public typealias PeerFilter = (_ info: String) -> ResponseQuery<Data>
