import Cosmos

extension GenesisState {
    // InitGenesis initialize default parameters
    // and the keeper's address to pubkey map
    static func initGenesis(request: Request, keeper: Keeper, data: GenesisState) {
        for record in data.whoisRecords {
            // TODO: Decide how to properly handle failure.
            try! keeper.setWhois(request: request, name: record.value, whois: record)
        }
    }

    // ExportGenesis writes the current store values
    // to a genesis file, which can be imported again
    // with InitGenesis
    static func exportGenesis(request: Request, keeper: Keeper) -> GenesisState {
        var records: [Whois] = []
        
        let iterator = keeper.getNamesIterator(request: request)
       
        while iterator.isValid {
            defer {
                iterator.next()
            }

            guard let name = String(data: iterator.key) else {
                continue
            }
            
            guard let whois = try? keeper.getWhois(request: request, key: name) else {
               continue
            }
            
            records.append(whois)
        }
        
        return GenesisState(whoisRecords: records)
    }
}

