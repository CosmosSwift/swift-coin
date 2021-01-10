import JSON

// AppParams defines a flat JSON of key/values for all possible configurable
// simulation parameters. It might contain: operation weights, simulation parameters
// and flattened module state parameters (i.e not stored under it's respective module name).
public typealias AppParameters = [String: JSON]

// ContentSimulatorFn defines a function type alias for generating random proposal
// content.
public typealias ContentSimulatorFunction = (_ random: RandomNumber, _ request: Request, _ accounts: [Account]) -> Content

//-----------------------------------------------------------------------------
// Param change proposals

// SimValFn function to generate the randomized parameter change value
public typealias SimulatorValueFunction = (_ random: RandomNumber) -> String

// ParamChange defines the object used for simulating parameter change proposals
public struct ParameterChange {
    let subspace: String
    let key: String
    let simulatorValue: SimulatorValueFunction
}


//-----------------------------------------------------------------------------
// Proposal Contents

// WeightedProposalContent defines a common struct for proposal contents defined by
// external modules (i.e outside gov)
public struct WeightedProposalContent {
    // key used to retrieve the value of the weight from the simulation application params
    let AppParametersKey: String
    // default weight
    let defaultWeight: Int
    // content simulator function
    let contentSimulatorFunction: ContentSimulatorFunction
}
