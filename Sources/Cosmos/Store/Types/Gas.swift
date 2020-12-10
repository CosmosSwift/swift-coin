// Gas consumption descriptors.
let gasIterNextCostFlatDescriptor = "IterNextFlat"
let gasValuePerByteDescriptor = "ValuePerByte"
let gasWritePerByteDescriptor = "WritePerByte"
let gasReadPerByteDescriptor = "ReadPerByte"
let gasWriteCostFlatDescriptor = "WriteFlat"
let gasReadCostFlatDescriptor = "ReadFlat"
let gasHasDescriptor = "Has"
let gasDeleteDescriptor = "Delete"

// Gas measured by the SDK
typealias Gas = UInt64

// GasMeter interface to track gas consumption
protocol GasMeter {
    var gasConsumed: Gas { get }
    var gasConsumedToLimit: Gas { get }
    var limit: Gas { get }
    func consumeGas(amount: Gas, descriptor: String)
    var isPastLimit: Bool { get }
    var isOutOfGas: Bool { get }
}


// GasConfig defines gas cost for each operation on KVStores
struct GasConfiguration {
    let hasCost: Gas
    let deleteCost: Gas
    let readCostFlat: Gas
    let readCostPerByte: Gas
    let writeCostFlat: Gas
    let writeCostPerByte: Gas
    let iterationNextCostFlat: Gas
}

// KVGasConfig returns a default gas config for KVStores.
extension GasConfiguration {
    static var keyValue: GasConfiguration {
        GasConfiguration(
            hasCost: 1000,
            deleteCost: 1000,
            readCostFlat: 1000,
            readCostPerByte: 3,
            writeCostFlat: 2000,
            writeCostPerByte: 30,
            iterationNextCostFlat: 30
        )
    }
}
