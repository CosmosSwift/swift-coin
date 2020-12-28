extension SupplyKeeper {
    // RegisterInvariants register all supply invariants
    func registerInvariants(in invariantRegistry: InvariantRegistry) {
        invariantRegistry.registerRoute(
            moduleName: SupplyKeys.moduleName,
            route: "total-supply",
            invariant: totalSupply
        )
    }

    // AllInvariants runs all invariants of the supply module.
    func allInvariants() -> Invariant {
        return { request in
            return totalSupply(request: request)
        }
    }

    // TotalSupply checks that the total supply reflects all the coins held in accounts
    func totalSupply(request: Request) -> (String, Bool) {
        var expectedTotal = Coins()
        let supply = self.supply(request: request)

        accountKeeper.iterateAccounts(request: request) { account in
            expectedTotal = expectedTotal + account.coins
            return false
        }

        let broken = expectedTotal != supply.total
        
        let invariant = formatInvariant(
            module: SupplyKeys.moduleName,
            name: "total supply",
            message: """
            \tsum of accounts coins: \(expectedTotal)
            \tsupply.total:          \(supply.total)\n
            """
        )
            
        return (invariant, broken)
    }
}
