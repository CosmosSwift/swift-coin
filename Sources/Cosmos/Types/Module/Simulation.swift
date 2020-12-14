import Foundation

// AppModuleSimulation defines the standard functions that every module should expose
// for the SDK blockchain simulator
protocol AppModuleSimulation {
    // randomized genesis states
    func generateGenesisState(input: SimulationState)

    // content functions used to simulate governance proposals
    func proposalContents(simumalationState: SimulationState) -> [WeightedProposalContent]

    // randomized module parameters for parameter change proposals
    func randomizedParameters(random: RandomNumber) -> [ParameterChange]

    // register a func to decode the each module's defined types from their corresponding store key
    func registerStoreDecoder(registry: StoreDecoderRegistry)

    // simulation operations (i.e msgs) with their respective weight
    func weightedOperations(simumlationState: SimulationState) -> [WeightedOperation]
}

// SimulationManager defines a simulation manager that provides the high level utility
// for managing and executing simulation functionalities for a group of modules
public struct SimulationManager {
    // array of app modules; we use an array for deterministic simulation tests
    let modules: [AppModuleSimulation]
    // functions to decode the key-value pairs from each module's store
    let storeDecoders: StoreDecoderRegistry
}

// SimulationState is the input parameters used on each of the module's randomized
// GenesisState generator function
struct SimulationState {
    let appParameters: AppParameters
    // application codec
    let codec: Codec
    // random number
    let random: RandomNumber
    // genesis state
    let genState: [String: RawMessage]
    // simulation accounts
    let accounts: [Account]
    // initial coins per account
    let initialStake: Int64
    // number of initially bonded accounts
    let numBonded: Int64
    // genesis timestamp
    let genTimestamp: Date
    // staking unbond time stored to use it as the slashing maximum evidence duration
    let unbondTime: TimeInterval
    // simulated parameter changes from modules
    let paramChanges: [ParameterChange]
    // proposal content generator functions with their default weight and app sim key
    let contents: [WeightedProposalContent]
}
