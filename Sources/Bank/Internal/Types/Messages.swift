import Cosmos

// Input models transaction input
public struct Input: Codable {
    let address: AccountAddress
    let coins: Coins
}

// Output models transaction outputs
public struct Output: Codable {
    let address: AccountAddress
    let coins: Coins
}
