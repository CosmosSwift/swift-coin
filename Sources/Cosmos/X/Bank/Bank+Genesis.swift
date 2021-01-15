
extension BankKeeper {
    // InitGenesis sets distribution information for genesis.
    func initGenesis(request: Request, state: BankGenesisState) {
        setSendEnabled(request: request, enabled: state.isSendEnabled)
    }

    // ExportGenesis returns a GenesisState for a given context and keeper.
    func exportGenesis(request: Request) -> BankGenesisState {
        BankGenesisState(isSendEnabled: isSendEnabled(request: request))
    }
}
