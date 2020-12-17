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
public typealias Gas = UInt64

// GasMeter interface to track gas consumption
public protocol GasMeter {
    var gasConsumed: Gas { get }
    var gasConsumedToLimit: Gas { get }
    var limit: Gas { get }
    mutating func consumeGas(amount: Gas, descriptor: String)
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

struct InfiniteGasMeter: GasMeter {
    var consumed: Gas
    
    init() {
        self.consumed = 0
    }
    
    var gasConsumed: Gas {
        consumed
    }
    
    var gasConsumedToLimit: Gas {
        consumed
    }

    var limit: Gas {
        0
    }
    
    mutating func consumeGas(amount: Gas, descriptor: String) {
        // TODO: Should we set the consumed field after overflow checking?
        let (consumed, overflow) = self.consumed.addingReportingOverflow(amount)
        self.consumed = consumed

        if overflow {
            fatalError("ErrorGasOverflow{\(descriptor)}")
        }
    }
    
    var isPastLimit: Bool {
        false
    }

    var isOutOfGas: Bool {
        false
    }
}
