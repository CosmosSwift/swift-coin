import JSON

// AppModuleBasic defines the basic application module used by the params module.
public struct ParamsAppModuleBasic: AppModuleBasic {
    public init() {}
    
    public var name: String = ParamsKeys.moduleName
    
    public func register(codec: Codec) {
        // TODO: Implement
        fatalError()
    }
    
    public func defaultGenesis() -> JSON? {
        nil
    }
    
    public func validateGenesis(json: JSON) throws {
        // TODO: Implement
        fatalError()
    }
}
