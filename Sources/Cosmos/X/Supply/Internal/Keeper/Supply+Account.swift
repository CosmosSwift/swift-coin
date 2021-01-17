extension SupplyKeeper {
    // GetModuleAddressAndPermissions returns an address and permissions based on the module name
    func moduleAddressAndPermissions(moduleName: String) -> (AccountAddress?, [String]) {
        guard let permissionAddress = permissionAddresses[moduleName] else {
            return (nil, [])
        }
        
        return (permissionAddress.address, permissionAddress.permissions)
    }

    // GetModuleAccountAndPermissions gets the module account from the auth account store and its
    // registered permissions
    func moduleAccountAndPermissions(request: Request, moduleName: String) -> (ModuleAccount?, [String]) {
        let (moduleAddress, permissions) = moduleAddressAndPermissions(moduleName: moduleName)

        guard let address = moduleAddress else {
            return (nil, [])
        }

        if let moduleAccount: ModuleAccount = accountKeeper.account(request: request, address: address) {
            return (moduleAccount, permissions)
        }

        // create a new module account
        let moduleAccount = ModuleAccount(
            name: moduleName,
            permissions: permissions
        )

        // set the account number
        let moduleAccountInterface = accountKeeper.makeAccount(request: request, account: moduleAccount) as! ModuleAccount
        // TODO: Check this force cast.
        setModuleAccount(request: request, moduleAccount: moduleAccountInterface)

        return (moduleAccountInterface, permissions)
    }

    // GetModuleAccount gets the module account from the auth account store
    func moduleAccount(request: Request, moduleName: String) -> ModuleAccount? {
        let (account, _) = moduleAccountAndPermissions(
            request: request,
            moduleName: moduleName
        )
        
        return account
    }
    
    // SetModuleAccount sets the module account to the auth account store
    func setModuleAccount(request: Request, moduleAccount: ModuleAccount) {
        accountKeeper.setAccount(request: request, account: moduleAccount)
    }

}
