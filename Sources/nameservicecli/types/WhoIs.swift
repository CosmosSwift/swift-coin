//
//  File.swift
//  
//
//  Created by Jaap Wijnen on 15/04/2021.
//

import Cosmos

struct WhoIs: Codable {
    let creator: AccountAddress
    let id: String
    let value: String
    let price: [Coin]
}
