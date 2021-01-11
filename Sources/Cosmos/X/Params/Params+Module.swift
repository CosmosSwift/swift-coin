import JSON

// AppModuleBasic defines the basic application module used by the params module.
public struct ParamsAppModuleBasic: AppModuleBasic {
    public init() {}
    
    public var name: String = ParamsKeys.moduleName
    
    public func register(codec: Codec) {
        // TODO: Implement
        fatalError()
    }
    
    /// DefaultGenesis returns default genesis state as raw bytes for the params
    /// module.
    public func defaultGenesis() -> JSON? {
        nil
    }
    
    /// ValidateGenesis performs genesis state validation for the params module.
    public func validateGenesis(json: JSON) throws {
    }
}
