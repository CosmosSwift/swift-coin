import Foundation
import ABCI


/// HistoricalInfo contains the historical information that gets stored at each height
struct HistoricalInfo: Codable {
    let header: Header
    let valSet: [Validator]

    /// NewHistoricalInfo will create a historical information struct from header and valset
    /// it will first sort valset before inclusion into historical info
    init(header: Header, valSet: [Validator]) {
        self.header = header
        // TODO: the validators should be sorted by address
        // sort.Sort(Validators(valSet))
        self.valSet = valSet //.sorted(by: { (v1, v2) -> Bool in
        //    v1.operatorAddress < v2.operatorAddress
        //})
    }
}


// MustMarshalHistoricalInfo wll marshal historical info and panic on error
func mustMarshalHistoricalInfo(codec: Codec, historicalInfo: HistoricalInfo) -> Data {
    codec.mustMarshalBinaryLengthPrefixed(value: historicalInfo)
}

// MustUnmarshalHistoricalInfo wll unmarshal historical info and panic on error
func mustUnmarshalHistoricalInfo(codec: Codec, value: Data) -> HistoricalInfo {
    guard let historicalInfo = try? unmarshalHistoricalInfo(codec: codec, value: value) else {
        fatalError("Failed to unmarshal Historical Info from data: \(value)")
    }
    return historicalInfo
}

// UnmarshalHistoricalInfo will unmarshal historical info and return any error
func unmarshalHistoricalInfo(codec: Codec, value: Data) throws -> HistoricalInfo {
    try codec.unmarshalBinaryLengthPrefixed(data: value)
}

// ValidateBasic will ensure HistoricalInfo is not nil and sorted
func validateBasic(historicalInfo: HistoricalInfo) throws {
    fatalError()
//    if historicalInfo.ValSet.count == 0 {
//        return sdkerrors.Wrap(ErrInvalidHistoricalInfo, "validator set is empty")
//    }
//    if !sort.IsSorted(Validators(hi.ValSet)) {
//        return sdkerrors.Wrap(ErrInvalidHistoricalInfo, "validator set is not sorted by address")
//    }
}