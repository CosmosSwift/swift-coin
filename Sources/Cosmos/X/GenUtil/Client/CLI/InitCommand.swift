import ArgumentParser

// InitCmd returns a command that initializes all files needed for Tendermint
// and the respective application.
public struct InitCommand: ParsableCommand {
    // TODO: Implement
    public static var configuration = CommandConfiguration(commandName: "init")
    
    public init() {}
}
